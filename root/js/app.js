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

    app.validateFields = function(email, username, password, confirmPassword) {
    	var errors = [];
        if (email == "") {
            errors.push("Email is empty");
        } else {
            var emailError = app.validateEmail(email);
            if (emailError) { errors.push(emailError); }
        }
        if (password == "") {
			errors.push("Password is empty");
		} else if (confirmPassword && password != confirmPassword) {
			errors.push("The passwords do not match.");
        }
        if (username == "") {
            errors.push("Username is empty");
        }
        return errors;
    };

    app.validateEmail = function (field) {
        var apos = field.indexOf("@"),
            dotpos = field.lastIndexOf(".");
        if (apos < 1 || dotpos - apos < 2) {
            return "Email address is not valid"
        } else {
            return null;
        }
    };

    
    app.showAlert = function (args) {
    	var $prependElement = args.prependTo || $('#content');
    	var items = args.items || [];
		var alertDiv = $("#cgc-alert");
		if (alertDiv.length > 0) {
			alertDiv.empty();
		} else {
			alertDiv = $("<div></div>");
			alertDiv.addClass("alert");
			alertDiv.attr('id', 'cgc-alert');
			$prependElement.prepend(alertDiv);
		}
        if (args.alertClass) {
            alertDiv.addClass(args.alertClass);
        }
		alertDiv
			.append('<button class="close" data-dismiss="alert">×</button>')
			.append('<h4 class="alert-heading">' + args.title + '</h4>');
		for (var i = 0; i < items.length; i++) {
			alertDiv.append(items[i] + "</br>");
		}
		if (args.fadeOut) {
			alertDiv.fadeOut(args.fadeOut);
		}
    }
    return app;
})(this);
