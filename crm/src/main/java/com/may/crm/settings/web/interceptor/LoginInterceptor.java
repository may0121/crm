package com.may.crm.settings.web.interceptor;

import com.may.crm.commons.constant.Constant;
import com.may.crm.settings.domain.User;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * @author may
 * @date 2022/4/27 18:58
 */
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o) throws Exception {
        /*1.判断session里面是否有user信息，即用户是否登陆
           2.如果用户已经登录，放行，没有登录则返回false，拦截请求
        * */
//        获取session里面的用户信息，拦截器不支持session注入，controller支持，只能通过request获取
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute(Constant.SESSION_USER);
        if (user==null){
//        用户为空则没有登录，拦截请求，跳转到登录页面，因为跳转到登录页面要重新刷新页面，所以用重定向
//            自定义的重定向要加上项目名，之前没有加，是因为springmvc框架已经自动加上了
            httpServletResponse.sendRedirect(httpServletRequest.getContextPath());//获取项目名，不写特定项目名称
            return false;
        }
//        用户已经登录，放行请求
        return true;

    }

    @Override
    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) throws Exception {

    }
}
