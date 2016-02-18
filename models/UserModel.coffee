'use strict'

MainModule.factory 'UserModel', () ->
    class UserModel
        model:'users'

        @relationStatus:
            0:
                id:0
                name:'0'
            1:
                id:1
                name:'свободен'
            2:
                id:2
                name:'гуляет с'
                other:'с кем то гуляет..'
            3:
                id:3
                name:'3'
            4:
                id:4
                name:'в брачных узах с'
                other:'с кем то в брачных узах..'
            5:
                id:5
                name:'замужем за'
            6:
                id:6
                name:'ищет пару'
            7:
                id:7
                name:'по уши влюблен в'
                other:'потеря разума..'

        @getRelationStatus: (user) ->
            if user.relation
                if user.relation_partner
                    relationStatus = UserModel.relationStatus[user.relation].name;
                else
                    switch user.relation
                        when 2
                            relationStatus = UserModel.relationStatus[user.relation].other;
                        when 4
                            relationStatus = UserModel.relationStatus[user.relation].other;
                        when 7
                            relationStatus = UserModel.relationStatus[user.relation].other;
                        else
                            relationStatus = UserModel.relationStatus[user.relation].name;

            else
                relationStatus = null;

            relationStatus;