#AnalysisFriendsController#

'use strict'

StatisticsFriendsModule.controller 'AnalysisFriendsController', ($scope, $state, familyStatus, posts, messages, universities, Static, Charts, params, friends, currentUser) ->

    $scope.loading = false;

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.currentUser = currentUser.response[0];
    $scope.global = () ->
        $state.transitionTo('statistics', {userId:$scope.currentUser.id});


    familyStatusesArray =  Static.filterFriendsListForFamilyStatus(friends.items);
    canPostsArray =  Static.filterFriendsListForParams(friends.items, 'can_post');
    canPrivateArray =  Static.filterFriendsListForParams(friends.items, 'can_write_private_message');
    canUniversitiesArray =  Static.filterFriendsListForParams(friends.items, 'universities');


    chart1 = angular.copy(Charts);
    chart1.data = [
        ['Component', 'cost'],
        [familyStatus.not , familyStatusesArray[0].length],
        [familyStatus.notMarried , familyStatusesArray[1].length],
        [familyStatus.meeting, familyStatusesArray[2].length]
        [familyStatus.engaged, familyStatusesArray[3].length]
        [familyStatus.married, familyStatusesArray[4].length]
        [familyStatus.complicated, familyStatusesArray[5].length]
        [familyStatus.active, familyStatusesArray[6].length]
        [familyStatus.loved, familyStatusesArray[7].length]
        [familyStatus.hide, familyStatusesArray[8].length]
    ];

    chart1.options.colors = ['#0598d8', '#f97263','#00ffff','#000080', '#ffff00', '#00ff00','#FF007F', '#800080', '#ff2400'];

    $scope.chart1 = chart1;


    chart2 = angular.copy(Charts);
    chart2.data = [
        ['Component', 'cost'],
        [posts.yes , canPostsArray[0].length],
        [posts.no , canPostsArray[1].length]
    ];

    chart2.options.colors = ['#0598d8', '#f97263'];

    $scope.chart2 = chart2;


    chart3 = angular.copy(Charts);
    chart3.data = [
        ['Component', 'cost'],
        [messages.yes , canPrivateArray[0].length],
        [messages.no , canPrivateArray[1].length]
    ];

    chart3.options.colors = ['#0598d8', '#f97263'];

    $scope.chart3 = chart3;

    chart4 = angular.copy(Charts);
    chart4.data = [
        ['Component', 'cost'],
        [universities.yes , canUniversitiesArray[0].length],
        [universities.no , canUniversitiesArray[1].length]
    ];

    chart4.options.colors = ['#0598d8', '#f97263'];

    $scope.chart4 = chart4;


