function add_flash_message(msg, ftype, mtype) {
  var flashtype;
  var flashmsg;
  var flashcontainer = $('<div>').addClass('alert-box').attr('data-alert', '');
  var flashclose = $('<a>').addClass('close').attr('href', '#').text('×');

  if (ftype == 'notice') {
    flashtype = 'success';
  } else {
    flashtype = 'alert';
  }

  if (mtype == 'html') {
    flashmsg = $('<div>').html(msg);
  } else {
    flashmsg = $('<div>').text(msg);
  }

  flashcontainer.addClass(flashtype).append(flashmsg).append(flashclose);
  $('messages > div.row > div').append(flashcontainer).promise().done(function() {
    $('messages').foundation('reflow');
  });
}

function flash_error(msg, mtype) {
  add_flash_message(msg, 'error', mtype);
}

function flash_notice(msg, mtype) {
  add_flash_message(msg, 'notice', mtype);
}

$(function() {
  jQuery.datepicker.setDefaults($.datepicker.regional['tr']);
  jQuery.timepicker.setDefaults($.timepicker.regional['tr']);

  $("input.datetimepicker").datetimepicker({hourGrid: 2, minuteGrid: 10});
  $('select.image-picker').imagepicker({ show_label: false });
});
