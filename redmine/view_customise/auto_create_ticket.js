const getChildTickets = function(isDevEffectFlag, pjtId, parentTicketId, createdDate, planedEndDate) {
  try { 
    if(isDevEffectFlag === '0') {
      return [
        {
          'issue': {
            'project_id': pjtId,
            'tracker_id': '7',
            'subject': 'テスト子チケット1',
            'priority_id': '2',
            'parent_issue_id': parentTicketId,
            'status_id': '8',
            'custom_fields': [
              { 'id': '14', 'value': createdDate },
              { 'id': '15', 'value': planedEndDate }
            ]
          }
        }
      ]
    } else {
       return [
        {
          'issue': {
            'project_id': pjtId,
            'tracker_id': '7',
            'subject': 'テスト子チケット1',
            'priority_id': '2',
            'parent_issue_id': parentTicketId,
            'status_id': '8',
            'custom_fields': [
              { 'id': '14', 'value': createdDate },
              { 'id': '15', 'value': planedEndDate }
            ]
          }
        },
        {
          'issue': {
            'project_id': pjtId,
            'tracker_id': '8',
            'subject': 'テスト子チケット2',
            'priority_id': '2',
            'parent_issue_id': parentTicketId,
            'status_id': '8',
            'custom_fields': [
              { 'id': '14', 'value': createdDate },
              { 'id': '15', 'value': planedEndDate }
            ]
          }
        }
      ]
    }
  } catch(e) {
    alert(e);
  }
}


const createTickets = function(childrenTickets) {
  return function() {
    return $.ajax({
      type: 'POST',
      url: '/issues.json',
      headers: {
        'X-Redmine-API-Key': ViewCustomize.context.user.apiKey
      },
      dataType: 'text',
      contentType: 'application/json',
      data: JSON.stringify(childrenTickets)
    });
  };
}

// メイン処理
$(function() {
  try {

    var pjtId = $('#issue_project_id').val();
    var parentTicketId = $('#issue_parent_issue_id').val();
    var isDevEffectFlag = $('#issue_custom_field_values_5').val();
    var createdDate = $('#issue_custom_field_values_14').val();
    var planedEndDate = $('#issue_custom_field_values_15').val();

    $('#issue-form').submit(function() {
      if($('#issue_tracker_id').val() === '6') {
        var defered = new $.Deferred();
        var promise = defered.promise();
        var childrenTickets = getChildrenTickets(isDevEffectFlag, pjtId, parentTicketId, createdDate, planedEndDate)

        for (var i = 0; i < childrenTickets.length; i++) {
          promise = promise.then(createTickets(childrenTickets[i]));
        }

        promise
          .done(function() {
            location.reload();
          })
          .fail(function() {
            alert('失敗しました');
          });

        defered.resolve();
      }
    });
  } catch(e) {
    alert(e);
  }
})
