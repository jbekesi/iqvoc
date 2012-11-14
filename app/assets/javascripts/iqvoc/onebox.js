/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.onebox = (function($) {

"use strict";

var renderResults = function(html, container) {
  var results = $("<div />").append(html).find("ol.concepts li");
  var pagination = $("<div />").append(html).find(".pagination");

  container.html(results);
  $(".pagination").remove();
  container.parent().append(pagination);
};

var getConcepts = function(input, container) {
  var form = input.closest("form");
  $.ajax({
    type: form.attr("method"),
    url: form.attr("action"),
    data: form.serialize(),
    success: function(data, status, xhr) {
      // disable scripts (adapted from jQuery's `load`)
      var rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
      var html = data.replace(rscript, "");

      renderResults(html, container);
    }
  });
};

var delay = (function() {
  var timer = 0;
  return function(callback, ms) {
    clearTimeout(timer);
    timer = setTimeout(callback, ms);
  };
})();

return function(selector, options) {
  var container = $(selector);
  var input = container.find("input[type=search]");
  var initialValue = input.val();
  var resultList = $("<ol />").addClass("results concepts unstyled").appendTo(container);

  input.keyup(function() {
    if (input.val().length == 0) {
      resultList.empty();
      $(".pagination").remove();
    }
    else if (input.val().length > 0 && input.val() != initialValue) {
      delay(function() { getConcepts(input, resultList) }, 300);
    }
  });
};

}(jQuery));
