#GlobalStatController#

'use strict';

MigrationsModule.controller 'GlobalStatController', ($scope, $stateParams, $state, RestModel, params, $timeout) ->

    #todo: константы
    $scope.menu = [
        {
            title:'Родной город'
            description:'Cтатистика по пользователям, проживающим в городах'
            url:'migrations'
        },
        {
            title:'Отношения Вконтакте'
            description:'Статистика по полу и отношениям'
            url:'relations'
        }
    ]

    $scope.goToStat = (state) ->
        $state.transitionTo(state);
        $scope.loading = true;

    $scope.home = () ->
        $state.transitionTo('friends');

