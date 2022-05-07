package com.may.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author may
 * @date 2022/4/26 16:13
 */
@Controller
public class WorkbenchIndexController {
//    跳转到首页页面
    @RequestMapping("/workbench/index.do")
    public String index(){
        return "workbench/index";
    }
}
