// SUBDOC
!function ($) {
	var Subdoc = function () {};
	Subdoc.prototype = {
		constructor: Subdoc
	};
	
	// jQuery.plugin
	$.fn.subdoc = function (options) {
		return this.each(function () {
		});
	};
	
	$.fn.subdoc.defaults = {};
	$.fn.modal.Constructor = Subdoc;

	// Initialization
	$(function () {
		$('body').on('click', '[data-uri]', function (e) {
			var $this = $(this);
			var target = $this.data('target');
			var uri    = $this.data('uri');
			$.ajax(uri, {
				success: function (data) {
					$(target).html(data);
				}
			});
		});
	});
}(window.jQuery);