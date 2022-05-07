package com.may.crm.commons.utils;

import java.util.UUID;

/**
 * @author may
 * @date 2022/4/28 16:05
 */
public class UUIDUtils {
   public static String getUUID(){
      String uuid= UUID.randomUUID().toString().replaceAll("-","");
      return uuid;
   }
}
