#MainContoller#

'use strict';

MainModule.controller 'MainController', ($scope, $location, $state, $http, $timeout, RestModel, LocalStorage, Notification) ->

    $scope.openAccess = false;
    $scope.content = {};
    $scope.send = false;

    $scope.linkPage = ['main', 'project', 'wishes'];
    $scope.select = $scope.linkPage[0];

    $scope.url = RestModel.getLinkAutorization();

    if window.location.href.indexOf("access_token") != -1
        $scope.openAccess = true;

        $scope.params = RestModel.getParams(window.location.href);
        LocalStorage.setItem('params', $scope.params);

        $state.transitionTo('friends');
    else
        if LocalStorage.getItem('params')
            $scope.openAccess = true;
            if window.location.pathname == '/login' || window.location.pathname == '/' then $state.transitionTo('friends');
        else
            Notification.show("Ошибка авторизации");


    $scope.sendWish = () ->
        $scope.send = true;
        reg = /^[\w\.\d-_]+@[\w\.\d-_]+\.\w{2,4}$/i;

        if !angular.isDefined($scope.content.email) || !angular.isDefined($scope.content.wish) || $scope.content.wish == '' || $scope.content.email == ''
            $scope.statusText = 'Не заполенено обязательное поле!';
            return true;

        else if !reg.test($scope.content.email)
            $scope.statusText = 'Неккоректный email';
            return true;

        else RestModel.getWish($scope.content).then(
                (data)->
                    $scope.statusText = 'Спасибо за отзыв';
                )



    #todo: возможно нужно будет реализовать серверную авторизацию