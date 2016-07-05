#GroupContentController#

'use strict';

GroupContentModule.controller 'GroupContentController', ($scope, $stateParams, $state, $timeout, Loader, $location, RestModel, Notification, LocalStorage, params, group) ->

    $scope.window = window;
    $scope.params = params;
    $scope.stateParams = $stateParams;
    $scope.loading = true;
    $scope.showAllUser = false;
    $scope.usersGroups = [];
    $scope.offset = 0;
    $scope.deactivated = [];
    $scope.localed = [];
    Loader.startLoad();

    $scope.userGroup = {};

    $scope.arrayAllUsers = [];

    $scope.group = group.response[0];

    $scope.getAllUsersInGroup = (countUser = null) ->


        if ($scope.group.is_closed != 2) && !$scope.group.deactivated

            if countUser is null then countUser = $scope.group.members_count;

            if countUser < 25000
                $timeout(()->
                    RestModel.getMemeberInGroup($scope.group.id, $scope.params, countUser, $scope.offset).then(
                        (data)->
                            angular.forEach(data.response, (item) ->
                                $scope.usersGroups.push(item.users);
                            )

                            $scope.offset = 0;
                            $scope.loading = false;

                            angular.forEach($scope.usersGroups, (arrayUsers)->
                                angular.forEach(arrayUsers, (user)->
                                    if user.deactivated then $scope.deactivated.push(user) else $scope.arrayAllUsers.push(user);
                                    if (user.city && $scope.group.city) && (user.city == $scope.group.city.id) then $scope.localed.push(user);
                                )

                            );

                            Loader.stopLoad();
                            $scope.procentDogs = Math.floor($scope.deactivated.length / $scope.group.members_count * 100);
                            $scope.procentLocal= Math.floor($scope.localed.length / $scope.group.members_count * 100);
                        (error)->
                            console.log(error);
                            $scope.getAllUsersInGroup(countUser);
                    )
                ,350)
            else
                $scope.arrayComments = [];
                $timeout(()->

                    RestModel.getMemeberInGroup($scope.group.id, $scope.params, countUser, $scope.offset).then(
                        (data)->
                            angular.forEach(data.response, (item) ->
                                $scope.usersGroups.push(item.users);

                                Loader.process(Math.floor($scope.usersGroups.length * 100 / Math.ceil($scope.group.members_count / 1000)));
                            )
                            $scope.offset = $scope.offset + 25000;
                            countUser = countUser - 25000;
                            $scope.getAllUsersInGroup(countUser);
                        (error)->
                            console.log(error);
                            $scope.getAllUsersInGroup(countUser);
                    )
                ,350);

        else
            $scope.loading = false;


    $scope.getAllUsersInGroup($scope.group.members_count);


    $scope.searchUsersLike = () ->
        $state.transitionTo('groupPostsLikes', {groupId:$scope.group.id, userId:$scope.userGroup.id});


    $scope.listGroups = () ->
        $state.transitionTo('groups');


    $scope.returnListFriends = () ->
        $state.transitionTo('friends');



    $scope.getUsers = () ->
        loading = true;
        itemHtml = "";
        $scope.arrayAllUsers.forEach((user)->
            if user.online
                itemHtml = itemHtml + '<tr><td class="blue text-center">' + user.id + '</td><td class="blue text-center">' + user.first_name + ' ' + user.last_name + '</td></tr>'
            else
                itemHtml = itemHtml + '<tr><td class="text-center">' + user.id + '</td><td class="text-center">' + user.first_name + ' ' + user.last_name + '</td></tr>'
        )

        $timeout(()->
            $('#body-table')[0].innerHTML = itemHtml;
        )

        loading = false;
        $scope.showAllUser = true;

