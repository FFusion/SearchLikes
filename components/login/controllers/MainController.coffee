#MainContoller#

'use strict';

MainModule.controller 'MainController', ($scope, $location, $state, $http, $timeout, RestModel, LocalStorage, Notification) ->

    $scope.content = {};
    $scope.send = false;

    $scope.url = RestModel.getLinkAutorization();
    console.log($scope.url);

    if window.location.href.indexOf("access_token") != -1
        $scope.params = RestModel.getParams(window.location.href);
        LocalStorage.setItem('params', $scope.params);

        RestModel.getWishUser($scope.params.user_id);

        $state.transitionTo('friends');
    else
        if LocalStorage.getItem('params')
            if window.location.pathname == '/login' || window.location.pathname == '/' then $state.transitionTo('friends');



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

