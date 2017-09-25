// Generated by CoffeeScript 1.7.1
'use strict';
CommentsGroupModule.controller('CommentsGroupController', function($scope, params, $stateParams, $timeout, RestModel, Notification, Loader, currentUser) {
  $scope.params = params;
  $scope.count = 0;
  $scope.window = window;
  $scope.group = {};
  $scope.type = {};
  $scope.type.searchType = "post";
  $scope.commentsOfUser = [];
  $scope.procent = 0;
  $scope.currentUserId = $stateParams.userId;
  $scope.currentUser = currentUser.response[0];
  $scope.isAnalisys = false;
  $scope.loading = false;
  $scope.result = false;
  $scope.stopped = false;
  $scope.lookedItems = false;
  $scope.onlyCurrent = true;
  $scope.back = function() {
    $scope.stopped = true;
    if (Loader.ID !== null) {
      Loader.stopLoad();
    }
    return $scope.window.history.back();
  };
  $scope.allFriends = angular.copy($scope.userFriends);
  $scope.analysisGroup = function() {
    $scope.isAnalisys = false;
    $scope.group.closed = false;
    return RestModel.getGroupById($scope.group.id, $scope.params).then(function(data) {
      $scope.group.name = data.response[0].name;
      if (angular.isDefined(data.response[0].counters)) {
        $scope.group.topicsCount = data.response[0].counters.topics;
      } else {
        $scope.group.topicsCount = 0;
      }
      if (data.response[0].is_closed === 0) {
        return RestModel.getAllWallPost($scope.group.id, $scope.params, 5, 0, true).then(function(data) {
          $scope.group.countItems = data.response.count;
          $scope.group.countComments = 0;
          angular.forEach(data.response.items, function(item) {
            return $scope.group.countComments += item.comments.count;
          });
          return $scope.isAnalisys = true;
        }, function(error) {
          return Notification.error(error);
        });
      } else {
        return $scope.group.closed = true;
      }
    }, function(error) {
      return Notification.error(error);
    });
  };
  $scope.getComments = function() {
    Loader.startLoad();
    $scope.isResultComments = [];
    $scope.result = true;
    $scope.stopped = false;
    $scope.procent = 0;
    $scope.count = 0;
    $scope.groupWall = [];
    $scope.offset = 0;
    $scope.commentsOfUser = [];
    return $scope.scanGroupComments();
  };
  $scope.scanGroupComments = function(count) {
    if (count == null) {
      count = null;
    }
    if (count === null) {
      $scope.offset = 0;
    }
    if (count === null) {
      count = parseInt($scope.group.searchItems);
    }
    if (count < 100 || count === null) {
      return $timeout(function() {
        return RestModel.getAllWallPost($scope.group.id, $scope.params, count || 100, $scope.offset, true).then(function(data) {
          $scope.groupWall.push(data.response.items);
          if (count <= 100) {
            return $scope.filteredPosts($scope.groupWall);
          } else {
            count = count - 100;
            $scope.offset = $scope.offset + 100;
            return $scope.scanGroupComments(count);
          }
        }, function(error) {
          return Notification.error(error);
        });
      }, 345);
    } else {
      return $timeout(function() {
        return RestModel.getAllWallPost($scope.group.id, $scope.params, 100, $scope.offset, true).then(function(data) {
          $scope.groupWall.push(data.response.items);
          count = count - 100;
          $scope.offset = $scope.offset + 100;
          return $scope.scanGroupComments(count);
        }, function(error) {
          return Notification.error(error);
        });
      }, 345);
    }
  };
  $scope.filteredPosts = function(postsArray) {
    var postsWithComment;
    postsWithComment = [];
    angular.forEach(postsArray, function(posts) {
      return angular.forEach(posts, function(post) {
        if (post.comments.count > 0) {
          return postsWithComment.push(post);
        }
      });
    });
    $scope.allPosts = postsWithComment.length;
    return $scope.getCommentsForPost(postsWithComment[0], postsWithComment);
  };
  $scope.getCommentsForPost = function(post, posts, count) {
    if (count == null) {
      count = null;
    }
    $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
    Loader.process($scope.procent);
    if (count === null) {
      $scope.offset = 0;
      count = post.comments.count;
    }
    if (!$scope.stopped) {
      if (count < 100) {
        return $timeout(function() {
          return RestModel.getCommentsWall(post.owner_id, post.id, $scope.params, count || 100, $scope.offset).then(function(data) {
            if (!data.error) {
              if (count === null) {
                count = data.response.count;
              }
              $scope.searchCurrentUser(post, data.response.items);
              if (count < 100) {
                posts.splice(0, 1);
                if (posts.length > 0) {
                  return $scope.getCommentsForPost(posts[0], posts);
                } else {
                  $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
                  return Loader.stopLoad();
                }
              } else {
                count = count - 100;
                $scope.offset = $scope.offset + 100;
                if (posts.length > 0) {
                  return $scope.getCommentsForPost(posts[0], posts, count);
                } else {
                  $scope.procent = 100 - Math.floor(posts.length * 100 / $scope.allPosts);
                  return Loader.stopLoad();
                }
              }
            } else {
              Notification.error('Произошла ошибка ' + data.error.error_msg);
              posts.splice(0, 1);
              if (posts.length > 0) {
                return $scope.getCommentsForPost(posts[0], posts);
              }
            }
          }, function(error) {
            Notification.error('Произошла ошибка ' + error.error_msg);
            posts.splice(0, 1);
            if (posts.length > 0) {
              return $scope.getCommentsForPost(posts[0], posts);
            }
          });
        }, 345);
      } else {
        return $timeout(function() {
          return RestModel.getCommentsWall(post.owner_id, post.id, $scope.params, count || 100, $scope.offset).then(function(data) {
            if (!data.error) {
              if (count === null) {
                count = data.response.count;
              }
              $scope.searchCurrentUser(post, data.response.items);
              if (count > 100) {
                count = count - 100;
                $scope.offset = $scope.offset + 100;
              } else {
                $scope.getCommentsForPost(posts[0], posts);
              }
              if (posts.length > 0) {
                return $scope.getCommentsForPost(posts[0], posts, count);
              }
            } else {
              Notification.error('Произошла ошибка ' + data.error.error_msg);
              posts.splice(0, 1);
              if (posts.length > 0) {
                return $scope.getCommentsForPost(posts[0], posts);
              }
            }
          }, function(error) {
            Notification.error('Произошла ошибка ' + error.error_msg);
            posts.splice(0, 1);
            if (posts.length > 0) {
              return $scope.getCommentsForPost(posts[0], posts);
            }
          });
        }, 345);
      }
    }
  };
  $scope.searchCurrentUser = function(post, comments) {
    var resultComments;
    resultComments = [];
    angular.forEach(comments, function(comment) {
      if (parseFloat(comment.from_id) === parseFloat($scope.currentUserId)) {
        comment.date = moment.unix(comment.date).format('DD.MM.YYYY HH:mm');
        return resultComments.push(comment);
      }
    });
    if (resultComments.length > 0) {
      return $scope.commentsOfUser.push({
        comments: resultComments,
        post: post
      });
    }
  };
  return $scope.stopScan = function() {
    return $scope.stopped = true;
  };
});

//# sourceMappingURL=CommentsGroupController.map
