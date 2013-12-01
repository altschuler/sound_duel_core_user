# Model
#

# Extend Meteor#Collection to support methods
# Embedded JavaScript:
`
Meteor.Kollection = Meteor.Collection;
Meteor.Kollection.extend = function(constructor) {
  var parent = this;
  var child = function() {
    Meteor.Kollection.apply(this, arguments);
    constructor.apply(this, arguments);
  };

  _.extend(child, parent);

  function __proto__() { this.constructor = child; };
  __proto__.prototype = parent.prototype;
  child.prototype = new __proto__;

  return child;
};

Meteor.Collection = Meteor.Kollection.extend(function(name, options) {
  if (options && options.defaults) {
    this.defaults = options.defaults;
  }
});

Meteor.Collection.prototype.applyDefaults = function(attrs) {
  return _.defaults(attrs, this.defaults);
};

Meteor.Collection.prototype.create = function(attrs) {
  if (typeof attrs !== "object") attrs = {};
  return this.applyDefaults(attrs);
};

Meteor.Collection.prototype.findOne = function(selector, options) {
  var object = Meteor.Kollection.prototype.findOne.apply(this, arguments);
  return this.applyDefaults(object);
};
`

# Collections

# Example:
# @Dogs = new Meteor.Collection("dogs",
#   defaults:
#     barkSound: "ruff"
#     bark: ->
#       console.log @barkSound
# )

@Sounds    = new Meteor.Collection('sounds',
  defaults:
    random_segment: ->
      if not @segments?.length then return null
      @segments[Math.floor(Math.random() * @segments.length)]
)

@Players   = new Meteor.Collection 'players'

@Games     = new Meteor.Collection 'games'

@Questions = new Meteor.Collection('questions',
  # defaults:
  #   random_elements: (number) ->
  #     count = @find().count()
  #     elements = []

  #     for x in [1..number]
  #       # find unique element
  #       while true
  #         rand = Math.floor(Math.random * count)
  #         element = @find({limit: -1}).skip(rand).next() # TODO: Doens't work
  #         if elements.indexOf(element) < 0
  #           elements.push element
  #           break

  #     elements
)
