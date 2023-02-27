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
    // 親チケット画面
    if($('#issue_tracker_id').val() === '4') {
      var ticketNumber = ViewCustomize.context.issue.id;
      alert(ticketNumber);
    // 子チケット画面
    } else if($('#issue_tracker_id').val() === '6') {
      var ticketNumber = ViewCustomize.context.issue.id;
      alert(ticketNumber);
    }
  } catch(e) {
    alert(e);
  }
})
