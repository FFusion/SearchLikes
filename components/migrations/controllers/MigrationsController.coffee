#MigrationsController#

'use strict';

MigrationsModule.controller 'MigrationsController', ($scope, $stateParams, $state, RestModel, params, $timeout) ->

    $scope.params = params;
    $scope.searching = false;

    $scope.home = () ->
        $state.transitionTo('friends');

    $scope.hometown = '';
    $scope.resUsers = [];
    $scope.resUserInMoskow = [];
    $scope.resUserInPiter = [];

    $scope.searchCountUsers = () ->
        $scope.searching = true;

        RestModel.getUsersHomeTown($scope.hometown, '', $scope.params).then(
            (data)->
                $scope.popularUsers = data.response.items;
                $scope.resUsers = [];
                $scope.resUsers.push({town:$scope.hometown, count:data.response.count});
#

                RestModel.getUsersHomeTown($scope.hometown, 1, $scope.params).then(
                    (data)->
                        $scope.resUserInMoskow = [];
                        if $scope.hometown != "Москва"
                            $scope.resUserInMoskow.push(text:'Переехали в Москву', count:data.response.count);
                        else
                            $scope.resUserInMoskow.push(text:'Живут в Москве', count:data.response.count);

                        RestModel.getUsersHomeTown($scope.hometown, 2, $scope.params).then(
                            (data)->
                                if $scope.hometown != "Санкт-Петербург"
                                    $scope.resUserInPiter = [];
                                    $scope.resUserInPiter.push(text:'Переехали в Санкт-Петербург', count:data.response.count);
                                else
                                    $scope.resUserInPiter.push(text:'Живут в Санкт-Петербурге', count:data.response.count);
                        )

                    (error)->
                        console.log(error);

                )
            (error) ->
                console.log(error);
        )

    $scope.refresh = () ->
        $scope.searching = false;