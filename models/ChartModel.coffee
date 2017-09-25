###
#ChartsService#
Работа с графиками
###

'use strict';

MainModule.factory 'Charts', ($timeout, $q, RestModel, Loader, Notification) ->
    class Charts

    type:'PieChart'
    data: []
    options:
        displayExactValues: true,
        width: '100%',
        height: '100%',
        pieSliceText: 'percentage',
        colors: ['#0598d8', '#f97263'],
        chartArea: {
            left: "3%",
            top: "3%",
            height: "94%",
            width: "94%"
        }
        is3D: true

    formatters: {
        number : [{
            columnNum: 1,
            pattern: "#,##0"
        }]
    }




