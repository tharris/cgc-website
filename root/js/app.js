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

var App = (function (window) {
    var app = {};

    // TODO: Bootstrapify
    app.validateFields = function(email, username, password, confirmPassword) {
        if (email.val() == "") {
            email.focus().addClass("ui-state-error");
            return false;
        } else if (email.val() &&
            !app.validateEmail(email.val(), "Not a valid email address!")) {
            email.focus().addClass("ui-state-error");
            return false;
        } else if (password) {
            if (password.val() == "") {
                password.focus().addClass("ui-state-error");
                return false;
            } else if (confirmPassword &&
                (password.val() != confirmPassword.val())) {
                alert("The passwords do not match. Please enter again");
                password.focus().addClass("ui-state-error");
                return false;
            }
        } else if (username && username.val() == "") {
            username.focus().addClass("ui-state-error");
            return false;
        } else {
            return true;
        }
    };

    app.validateEmail = function (field, alerttxt) {
        var apos = field.indexOf("@"),
            dotpos = field.lastIndexOf(".");
        if (apos < 1 || dotpos - apos < 2) {
            alert(alerttxt);
            return false;
        } else {
            return true;
        }
    };
    return app;
})(this);
