#MainContoller#

'use strict';

MainModule.controller 'MainController', ($scope, $location, $http, $timeout, RestModel, LocalStorage, Notification) ->

    $scope.openAccess = false;
    $scope.content = {};

    $scope.linkPage = ['main', 'project', 'wishes'];
    $scope.select = $scope.linkPage[0];

    $scope.url = RestModel.getLinkAutorization();


    if window.location.href.indexOf("access_token") != -1
        $scope.openAccess = true;

        $scope.params = RestModel.getParams(window.location.href);
        LocalStorage.setItem('params', $scope.params);

        window.location.hash = '';
#        window.location.href = 'http://localhost/friends';
        window.location.href = 'http://vkopen.16mb.com/friends';

    else
        if LocalStorage.getItem('params')
            $scope.openAccess = true;
            if window.location.pathname == '/login' || window.location.pathname == '/' then $location.path('/friends');
        else
            #todo: придумать обработку ошибки отсутствия token
            $scope.error = "error";


    $scope.selectMain = () ->
        console.log(1);
        $scope.select = $scope.linkPage[0];


    $scope.selectProject = () ->
        console.log(2);
        $scope.select = $scope.linkPage[1];


    $scope.selectWishes = () ->
        console.log(3);
        $scope.select = $scope.linkPage[2];


    $scope.sendWish = () ->
        reg = /^[\w\.\d-_]+@[\w\.\d-_]+\.\w{2,4}$/i;

        if !angular.isDefined($scope.content.email) || !angular.isDefined($scope.content.wish) || $scope.content.wish == '' || $scope.content.email == ''
            Notification.show('Не заполенено обязательное поле!');
            return true;

        else if !reg.test($scope.content.email)
            Notification.show('Неккоректный email');
            return true;

        else RestModel.getWish($scope.content).then((data)->
                Notification.show("Спасибо за отзыв");
                $scope.content = {};
                $timeout(()->
                    $location.path('/login');
                ,2000)
            )



    #todo: возможно нужно будет реализовать серверную авторизацию