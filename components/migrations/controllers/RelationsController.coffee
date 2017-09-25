#RelationsController#

'use strict';

MigrationsModule.controller 'RelationsController', ($scope, $stateParams, $state, familyStatus, Charts, sex, man, woman, notMarried, meeting, engaged, married, complicated, active, loved) ->


    $scope.loading = false;

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.global = () ->
        $state.transitionTo('global');



    chart1 = angular.copy(Charts);
    chart1.data = [
        ['Component', 'cost'],
        [sex.woman, woman.response.count],
        [sex.man, man.response.count]
    ];

    chart1.options.colors = ['#0598d8', '#f97263'];

    $scope.chart1 = chart1;



    chart2 = angular.copy(Charts);
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
    chart2.options.colors = ['#0598d8', '#f97263','#00ffff','#000080', '#ffff00', '#00ff00','#FF007F'];


    $scope.chart2 = chart2;