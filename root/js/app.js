$(function () {
	$("a[rel=popover]").popover().click(function(e) {
		e.preventDefault()
	});
});

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
		$('body').on('click.subdoc.data-api', '[data-uri]', function (e) {
			var $this = $(this);
			var href;
			var $target = $($this.data('target') ||
				(href = $this.attr('href')) &&
				 	href.replace(/.*(?=#[^\s]+$)/, '')); //strip for ie7	
			var uri = $this.data('uri');
			$.ajax(uri, {
				data: { inline: true },			
				success: function (data) {
					$target.html(data);
				}
			});
		});
	});
}(window.jQuery);