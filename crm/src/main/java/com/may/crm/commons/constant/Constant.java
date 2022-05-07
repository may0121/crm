package com.may.crm.commons.constant;

/**
 * @author may
 * @date 2022/4/26 17:16
 */
public class Constant {
//    封装returnobject里面的code属性
    public static final String RETURN_OBJECT_CODE_SUCCESS = "1";//成功
    public static final String RETURN_OBJECT_CODE_FAIL = "0";//失败

//    设置session的key
    public static final String SESSION_USER = "sessionUser";

    // 设置导出市场活动文件名（注意：只能为excel文件，加上拓展名：.xsl）
    public static final String FILE_NAME_ACTIVITY = "activityList.xls";

    // 注册账号的一些信息
    public static final String ACT_LOCK_STATE_FALSE = "1"; // 非锁定状态
    public static final String ACT_LOCK_STATE_TRUE = "0"; // 锁定状态

    // 市场活动备注是否修改过
    public static final String REMARK_EDIT_FLAG_FALSE = "0"; // 没有修改过
    public static final String REMARK_EDIT_FLAG_TRUE = "1"; // 修改过
}
