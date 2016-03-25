'use strict'

MainModule.factory 'UserModel', () ->
    class UserModel
        model:'users'

        @relationStatus:
            0:
                id:0
                name:'-'
            1:
                id:1
                male:'свободный парень'
                female:'свободная девушка'
            2:
                id:2
                name:'дружит с '
                other:'с кем то гуляет..'
            3:
                id:3
                male:'помолвлен'
                female:'помолвлена'
                maleOther:'помолвлен с '
                femaleOther:'помолвлена с '
            4:
                id:4
                male:'есть жена - '
                female:'есть муж -'
                maleOther:'женат'
                femaleOther:'замужем'
            5:
                id:5
                name:'все непонятно'
                other:'все непонятно c '
            6:
                id:6
                name:'активно ищет пару'
            7:
                id:7
                male:'влюблен'
                female:'влюблена'
                maleOther:'влюблен в '
                femaleOther:'влюблена в '


        @getRelationStatus: (user) ->
            if user.relation
                if user.relation_partner
                    if user.sex == 1
                        switch user.relation
                            when 2
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 3
                                relationStatus = UserModel.relationStatus[user.relation].femaleOther;
                            when 4
                                relationStatus = UserModel.relationStatus[user.relation].female;
                            when 5
                                relationStatus = UserModel.relationStatus[user.relation].other;
                            when 7
                                relationStatus = UserModel.relationStatus[user.relation].femaleOther;
                    else
                        switch user.relation
                            when 2
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 3
                                relationStatus = UserModel.relationStatus[user.relation].maleOther;
                            when 4
                                relationStatus = UserModel.relationStatus[user.relation].male;
                            when 5
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 7
                                relationStatus = UserModel.relationStatus[user.relation].maleOther;

#                    relationStatus = UserModel.relationStatus[user.relation].name;
                else
                    if user.sex == 1
                        switch user.relation
                            when 1
                                relationStatus = UserModel.relationStatus[user.relation].female;
                            when 2
                                relationStatus = UserModel.relationStatus[user.relation].other;
                            when 3
                                relationStatus = UserModel.relationStatus[user.relation].female;
                            when 4
                                relationStatus = UserModel.relationStatus[user.relation].femaleOther;
                            when 5
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 6
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 7
                                relationStatus = UserModel.relationStatus[user.relation].female;
                    else
                        switch user.relation
                            when 1
                                relationStatus = UserModel.relationStatus[user.relation].male;
                            when 2
                                relationStatus = UserModel.relationStatus[user.relation].other;
                            when 3
                                relationStatus = UserModel.relationStatus[user.relation].male;
                            when 4
                                relationStatus = UserModel.relationStatus[user.relation].maleOther;
                            when 5
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 6
                                relationStatus = UserModel.relationStatus[user.relation].name;
                            when 7
                                relationStatus = UserModel.relationStatus[user.relation].male;


            else
                relationStatus = null;

            relationStatus;