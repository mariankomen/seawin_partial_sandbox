AcctSeed.ASModule = function(a, b, c, d) {
    "use strict";
    var e, f = [];
    d.addAttachments = function(a, b) {
        f = f.concat(a), g(f)
    };
    var g = function(a) {
            void 0 !== e && e.destroy(), e = c('[id$="mainTable"]').DataTable({
                data: a,
                paging: !1,
                lengthChange: !1,
                pageLength: 10,
                searching: !1,
                ordering: !1,
                info: !1,
                autoWidth: !1,
                columns: [{
                    title: "Name",
                    data: "fileName"
                }, {
                    title: "Size",
                    data: "fileSize",
                    render: function(a, b, c, e) {
                        return d.fileSizeFormatter(a, 3)
                    },
                    className: "dt-head-right dt-body-right"
                }, {
                    title: "Action",
                    data: "fileId",
                    render: function(a, b, c, d) {
                        return "<a href='#' id='" + a + "' class='cancelAttachment'><span style='color: red;'>Cancel</span></a>"
                    },
                    className: "dt-head-center dt-body-center"
                }]
            }), c('[id$="proxyInput"]').val(JSON.stringify(a)), c(".cancelAttachment").on("click", function() {
                var a = this;
                h(c(a).attr("id"))
            })
        },
        h = function(a) {
            for (var b = [], c = 0; c < f.length; c++) f[c].fileId !== a && b.push(f[c]);
            f = b, g(f)
        };
    d.setCustomStyleOnBtn = function(a) {
        c(".btn").toggleClass("btnDisabled").val(a)
    }, d.newWin = null, d.openCustomFilePicker = function(b) {
        var c = b;
        return d.newWin = a.open(c, "Popup", "height=550,width=780,left=200,top=200,resizable=no,scrollbars=no,toolbar=no,status=no"), a.focus && d.newWin.focus(), !1
    }, d.closeCustomFilePicker = function() {
        null != d.newWin && d.newWin.close()
    }, d.setContact = function(a, b) {
        function e(a, b) {
            if (b.status)
                if (a.isValidContact) {
                    if ("undefined" == typeof CKEDITOR || null === CKEDITOR) "" == c('[id$="emailSubject"]').val() && c('[id$="emailSubject"]').val(a.template.emailSubject), "" == c('[id$="emailBody"]').val() && c('[id$="emailBody"]').val(a.template.emailBody);
                    else {
                        "" == c('[id$="emailSubject"]').val() && c('[id$="emailSubject"]').val(a.template.emailSubject);
                        var d = c('[id$="emailBody"]').attr("id"),
                            e = a.template.emailBody;
                        "" == CKEDITOR.instances[d].getData() && CKEDITOR.instances[d].setData(e)
                    }
                    c('[id$="emailAttachButton"]').attr("disabled", !1), c('[id$="emailAttachButton"]').addClass("btn"), c('[id$="emailAttachButton"]').removeClass("btnDisabled"), c('[id$="errorPanel"]').hide()
                } else i(a.errorMessage);
            else i(b.message)
        }
        Visualforce.remoting.Manager.invokeAction(d.setContactRemote, a, b, e, {
            escape: !1,
            timeout: 12e4
        })
    };
    var i = function(a) {
            j(a), c('[id$="emailAttachButton"]').attr("disabled", "disabled"), c('[id$="emailAttachButton"]').addClass("btnDisabled")
        },
        j = function(a) {
            a && (c('[id$="errorPanel"]').show(), c('[id$="errorPanel"]').html("Error: " + a))
        };
    return d.validateEmails = function() {
        c('[id$="emailErrorPanel"]').hide();
        var a = !0;
        return c(".tag").each(function() {
            c(this).hasClass("notValid") && (a = !1)
        }), a ? d.setCustomStyleOnBtn("Processing...") : (c('[id$="emailErrorPanel"]').show(), c('[id$="emailErrorPanel"]').find("h4").html("One or more Ð¡Ð¡ Addresses are not valid."), !1)
    }, c(b).ready(function() {
     }), d
}(window, document, $j, AcctSeed.ASModule);