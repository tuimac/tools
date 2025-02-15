Highcharts.charts[0].update({
  series: [{
    dataLabels: {
      enabled: true,
      formatter: function() {
        return Highcharts.numberFormat(this.y, 2, '.', ',');
      }
    }
  }] 
});
	
