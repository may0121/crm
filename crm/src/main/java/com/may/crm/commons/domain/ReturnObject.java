package com.may.crm.commons.domain;

/**
 * @author may
 * @date 2022/4/25 18:07
 */
// 创建类转json
public class ReturnObject {
    private String code;//处理成功或失败的标记，1成功，0失败
    private String message;//提示信息
    private Object other;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getOther() {
        return other;
    }

    public void setOther(Object other) {
        this.other = other;
    }
}
