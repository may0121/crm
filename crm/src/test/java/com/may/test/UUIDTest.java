package com.may.test;

import java.util.UUID;

/**
 * @author may
 * @date 2022/4/28 15:48
 */
public class UUIDTest {
    public static void main(String[] args) {
//    UUID.randomUUID() 这是一个对象不能直接打印信息，必须调用tostring方法
        String uuid = UUID.randomUUID().toString().replaceAll("-","");
        System.out.println(uuid);
    }
}
