// Generated by CoffeeScript 1.7.1
'use strict';
SelectedModule.controller('SelectedController', function($scope, $stateParams, $location, $timeout, RestModel, params) {
  $scope.params = params;
  $scope.window = window;
  $scope.stateParams = $stateParams;
  $scope.loading = true;
  $scope.userId = $scope.stateParams.userId;
  $scope.type = $scope.stateParams.type;
  $scope.selected = null;
  $scope.page = 1;
  $scope.pageSize = 7;
  $scope.back = function() {
    return $scope.window.history.back();
  };
  RestModel.getUserById($scope.userId, $scope.params).then(function(data) {
    return $scope.currentUser = data.response[0];
  }, function(error) {
    return console.log(error);
  });
  RestModel.getFriends(params, $scope.userId).then(function(data) {
    $scope.loading = false;
    $scope.countFriends = data.response.count;
    return $scope.userFriends = RestModel.isWorkingFriendsObject(data);
  }, function(error) {
    return console.log(error);
  });
  $scope.isSelected = function(selected) {
    if ($scope.selected !== null && selected === $scope.selected) {
      return $scope.selected = null;
    } else {
      return $scope.selected = selected;
    }
  };
  return $scope.selectUserNext = function() {
    return $location.path('user/' + $scope.userId + '/selected/' + $scope.selected.id + '/' + $scope.type);
  };
});

//# sourceMappingURL=SelectedController.map
