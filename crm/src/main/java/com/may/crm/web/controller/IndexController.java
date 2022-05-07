package com.may.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author may
 * @date 2022/4/25 11:17
 */
@Controller
public class IndexController {
    /*"/“代表之前完整的路径http://127.0.0.1:8080/crm/，
    之后从“/"开始访问
    * */
    @RequestMapping("/")
    public String index(){
/*
*      <property name="prefix" value="/WEB-INF/pages"/>
*      <property name="suffix" value=".jsp"/>
*           在springmvc 配置视图解析器里面已经设置好了地址和后缀
* */

        return "index";
    }
}
