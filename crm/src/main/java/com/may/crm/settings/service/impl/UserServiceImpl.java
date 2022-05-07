package com.may.crm.settings.service.impl;

import com.may.crm.settings.domain.User;
import com.may.crm.settings.mapper.UserMapper;
import com.may.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author may
 * @date 2022/4/25 15:52
 */
@Service("userService")
public class UserServiceImpl implements UserService {

@Autowired
private UserMapper userMapper;
    @Override
    public User selectUserByLoginActAndPwd(Map<String, Object> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> selectAllUsers() {
        return userMapper.selectAllUsers();
    }
}
