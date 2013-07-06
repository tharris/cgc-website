$(function () {
	$("a[rel=popover]").popover().click(function(e) {
		e.preventDefault()
	});
});

//
//$(function () {
//	$('input.workflow-checkbox').prettyCheckable({
//		color:'green';
//	    })
//	    })

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

/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
	sWrapper: "dataTables_wrapper form-inline"
} );

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
	return {
		iStart:         oSettings._iDisplayStart,
		iEnd:           oSettings.fnDisplayEnd(),
		iLength:        oSettings._iDisplayLength,
		iTotal:         oSettings.fnRecordsTotal(),
		iFilteredTotal: oSettings.fnRecordsDisplay(),
		iPage:          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
		iTotalPages:    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
	};
}

$(function () {
/* Bootstrap style pagination control */
$.extend($.fn.dataTableExt.oPagination, {
	bootstrap: {
		fnInit: function( oSettings, nPaging, fnDraw ) {
			var oLang = oSettings.oLanguage.oPaginate;
			var fnClickHandler = function ( e ) {
				e.preventDefault();
				if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
					fnDraw( oSettings );
				}
			};

			$(nPaging).addClass('pagination').append(
				'<ul>'+
					'<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
					'<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
				'</ul>'
			);
			var els = $('a', nPaging);
			$(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
			$(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
		},

		fnUpdate: function ( oSettings, fnDraw ) {
			var iListLength = 5;
			var oPaging = oSettings.oInstance.fnPagingInfo();
			var an = oSettings.aanFeatures.p;
			var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

			if ( oPaging.iTotalPages < iListLength) {
				iStart = 1;
				iEnd = oPaging.iTotalPages;
			}
			else if ( oPaging.iPage <= iHalf ) {
				iStart = 1;
				iEnd = iListLength;
			} else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
				iStart = oPaging.iTotalPages - iListLength + 1;
				iEnd = oPaging.iTotalPages;
			} else {
				iStart = oPaging.iPage - iHalf + 1;
				iEnd = iStart + iListLength - 1;
			}

			for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
				// Remove the middle elements
				$('li:gt(0)', an[i]).filter(':not(:last)').remove();

				// Add the new list items and their event handlers
				for ( j=iStart ; j<=iEnd ; j++ ) {
					sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
					$('<li '+sClass+'><a href="#">'+j+'</a></li>')
						.insertBefore( $('li:last', an[i])[0] )
						.bind('click', function (e) {
							e.preventDefault();
							oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
							fnDraw( oSettings );
						} );
				}

				// Add / remove disabled classes from the static elements
				if ( oPaging.iPage === 0 ) {
					$('li:first', an[i]).addClass('disabled');
				} else {
					$('li:first', an[i]).removeClass('disabled');
				}

				if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
					$('li:last', an[i]).addClass('disabled');
				} else {
					$('li:last', an[i]).removeClass('disabled');
				}
			}
		}
	}
});
});

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&;]" + name + "=([^&;#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if (results == null) return "";
    else return decodeURIComponent(results[1].replace(/\+/g, " "));
}



