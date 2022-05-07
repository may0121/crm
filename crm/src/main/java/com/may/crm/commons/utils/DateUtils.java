package com.may.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author may
 * @date 2022/4/26 17:01
 */
public class DateUtils {
    //格式化日期时间
    public static String formateDateTime(Date date) {
        SimpleDateFormat now = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String format = now.format(date);
        return format;
    }

    //格式化日期
    public static String formateDate(Date date) {
        SimpleDateFormat now = new SimpleDateFormat("yyyy-MM-dd");
        String format = now.format(date);
        return format;
    }
    //格式化时间
    public static String formateTime(Date date) {
        SimpleDateFormat now = new SimpleDateFormat("HH:mm:ss");
        String format = now.format(date);
        return format;
    }
}
