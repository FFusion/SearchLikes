#RelationsController#

'use strict';

MigrationsModule.controller 'RelationsController', ($scope, $stateParams, $state, familyStatus, sex, man, woman, notMarried, meeting, engaged, married, complicated, active, loved) ->


    $scope.loading = false;

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.global = () ->
        $state.transitionTo('global');


    chart1 = {};
    chart1.type = "PieChart";
    chart1.data = [
        ['Component', 'cost'],
        [sex.woman, woman.response.count],
        [sex.man, man.response.count]
    ];
    chart1.options = {
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
    };

    chart1.formatters = {
        number : [{
            columnNum: 1,
            pattern: "#,##0"
        }]
    };

    $scope.chart1 = chart1;



    chart2 = {};
    chart2.type = "PieChart";
    chart2.data = [
        ['Component', 'cost'],
        [familyStatus.notMarried , notMarried.response.count],
        [familyStatus.meeting, meeting.response.count]
        [familyStatus.engaged, engaged.response.count]
        [familyStatus.married, married.response.count]
        [familyStatus.complicated, complicated.response.count]
        [familyStatus.active, active.response.count]
        [familyStatus.loved, loved.response.count]
    ];
    chart2.options = {
        displayExactValues: true,
        width: '100%',
        height: '100%',
        pieSliceText: 'percentage',
        colors: ['#0598d8', '#f97263','#00ffff','#000080', '#ffff00', '#00ff00','#FF007F'],
        chartArea: {
            left: "3%",
            top: "3%",
            height: "94%",
            width: "94%"
        }
        is3D: true
    };

    chart2.formatters = {
        number : [{
            columnNum: 1,
            pattern: "#,##0"
        }]
    };


    $scope.chart2 = chart2;