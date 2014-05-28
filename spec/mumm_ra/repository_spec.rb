require "spec_helper"
require "mumm_ra/repository"
require "ostruct"
require "rb_toolbox/struct"

Point = RbToolbox::Struct.new(:x, :y)

module MummRa
  describe Repository do
    context "initialization" do
      context "with source and main_class" do
        When(:repo) { Repository.new(source: :source, main_class: :main_class) }
        Then { expect(repo).not_to have_failed }
      end

      context "without source" do
        When(:repo) { Repository.new(main_class: :main_class) }
        Then { expect(repo).to have_failed(KeyError, "key not found: :source") }
      end

      context "without main_class" do
        When(:repo) { Repository.new(source: :source) }
        Then { expect(repo).to have_failed(KeyError, "key not found: :main_class") }
      end
    end

    context "enumeration" do
      Given(:repo) { Repository.new(source: source, main_class: nil) }
      Given(:source) {
        {
          "one"   => "One",
          "two"   => "Two",
          "three" => "Three",
        }
      }
      Given(:values) { %W[One Two Three] }
      Then { repo.all == values }
      Then {
        repo.each do |value|
          value == values.shift
        end
      }
      Then { repo.is_a? Enumerable }
    end


    context "fetching and constructing" do
      Given(:main_class) { Point }
      Given(:first)  { Point.new(x: 0, y: 0) }
      Given(:second) { Point.new(x: 1, y: 1) }
      Given(:source) {
        {
          "first"  => first,
          "second" => second,
        }
      }
      Given(:repo) { Repository.new(source: source, main_class: main_class) }

      context "#[]" do
        Then { repo["first"] == first }
        Then { repo["third"] == nil }
      end

      context "#construct_from_object" do
        #Invariable { repo.construct_from_object.is_a?(main_class) }
        Given(:point)  { Point.new(x: 1, y: 2) }
        Given(:hash)   { {x: 3, y: 4} }
        Given(:object) { OpenStruct.new(x: 5, y: 6) }

        When(:point1) { repo.construct_from_object(point) }
        When(:point2) { repo.construct_from_object(hash) }
        When(:point3) { repo.construct_from_object(object) }

        Then { point1.is_a? Point }
        Then { point1.x == 1 }
        Then { point1.y == 2 }

        Then { point2.is_a? Point }
        Then { point2.x == 3 }
        Then { point2.y == 4 }

        Then { point3.is_a? Point }
        Then { point3.x == 5 }
        Then { point3.y == 6 }

      end
    end
  end
end
