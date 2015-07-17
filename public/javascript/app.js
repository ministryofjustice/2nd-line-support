$(document).ready(function() {
  fetchJSON();
  update();

  setInterval(function() {
    fetchJSON();
    update();
  }, 3000);
});

function fetchJSON() {
  $.getJSON('/v2-admin.json')
    .done(function(data) {
      localStorage.setItem('json', JSON.stringify(data));
      // localStorage.setItem('version', data['version'])
    });
}

function update() {
  json = localStorage.getItem('json');
  var data = JSON.parse(json)
  console.log(data);

  if(parseInt(data['number_of_alerts']) > 0) {
    $('body').addClass('alert');
  }

  updatePastWeek(data);
  updateOnDuty(data);
  updateOutOfHours(data);
}

function updateOnDuty(data) {
  $('#on-duty').empty();

  $('#on-duty').append(
    '<li class="webop">' + data['duty_roster']['web_ops'] + '</li>'
  );

  updateRoster('dev', '#on-duty', data);

  $('#on-duty').append(
    '<li class="duty_manager">' + data['duty_roster']['irm'] + '</li>'
  );
}

function updateOutOfHours(data) {
  $('#out-of-hours').empty();
  updateRoster('ooh', '#out-of-hours', data);
}

function updateRoster(memberType, container, data) {
  for(var i = 1; i <= 2; i++) {
    if(data['duty_roster'][memberType + '_' + i]) {
      var member = data['duty_roster'][memberType + '_' + i];

      $(container).append(
        '<li class="' + memberType + '">' + member + '</li>'
      );
    }
  }
}

function updatePastWeek(data) {
  $('#past_week').text(data['status_bar_text']);
}
