package com.may.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author may
 * @date 2022/4/28 12:08
 */
//跳转到窗口切面的页面
@Controller
public class MainController {
    @RequestMapping("/workbench/main/index.do")
    public String index(){
// main下面的index页面
        return "workbench/main/index";

    }
}
