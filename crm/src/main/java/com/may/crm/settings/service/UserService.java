package com.may.crm.settings.service;

import com.may.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserService {
//    用户登录
    User selectUserByLoginActAndPwd(Map<String,Object> map);
//    查询所有用户信息
    List<User> selectAllUsers();
}
