package com.may.crm.settings.web.controller;

import com.may.crm.commons.constant.Constant;
import com.may.crm.commons.domain.ReturnObject;
import com.may.crm.commons.utils.DateUtils;
import com.may.crm.settings.domain.User;
import com.may.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * @author may
 * @date 2022/4/25 13:12
 */
//在不同controller包下面一定要在springmvc中进行包扫描！！
@Controller
public class UserController {
    @Autowired
    private UserService userService;
    /**
     *1.url 要和controller方法处理完请求之后响应信息返回的页面资源目录保持一致
     * 2.原路径  /WEB-INF/pages/settings/qx/user/toLogin
     * 3.因为视图解析器已经配置了前缀和后缀所以只需要写/settings/qx/user/toLogin
     * 4.controller后缀 do 也可以不写
     */
    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin(){
//        跳转到登录页面， 这里没有“/”是因为前缀有
     return "settings/qx/user/login";
    }

    /**
     * 登录信息
     * 1.使用Object返回值因为后面要生成json对象，响应给前端
     * 2.json对象要使用responseBody
     * 3.登录页面要记录的信息分别是，用户名，密码，是否记住我，方法的形参也是这个（确定为String类型更方便管理）
     * 4.mapping的地址要跟返回的地址是一样的,最后还是到登录页面
     *
     */
    @RequestMapping("/settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpSession session, HttpServletResponse response){
//       1.用map来封装参数（记住我是不需要传值的）
        Map<String,Object> map = new HashMap<>();
//       2.这里的key值要与mapper配置文件里面的参数一致
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
//       3.调service方法查询用户信息(controller 就相当于servlet)
        User user = userService.selectUserByLoginActAndPwd(map);


//       4.对信息进行判断
//      创建工具类转存json对象,生成响应信息
        ReturnObject object = new ReturnObject();
        if (user==null){
//       说明没有这个用户，那么就是账号错误或密码错误，登录失败
            object.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            object.setMessage("账号或密码错误，登录失败");
        }else{//如果这个账号和密码没有问题，接下来对其他条件进行判断
            /**
             *1.把时间转成字符串用comparaTo比较，如果现在的没时间大，说明当前账号已经过期了
             *2."yyyy-MM-dd HH:mm:ss"  先把当前日期格式化为相同格式的字符串
             *3.比较大小
             */

//            DateUtils.formateDateTime(new Date())
//            SimpleDateFormat now = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String formatNow = DateUtils.formateDateTime(new Date());
            if (formatNow.compareTo(user.getExpireTime())>0){
//           账号已过期，登录失败
            object.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
            object.setMessage("账号已过期，登录失败");
//           判断账号状态是否被锁定
            } else if ("0".equals(user.getLockState())){
//            状态为0，账号被锁定，无法登录
                object.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                object.setMessage("账号被锁定，登录失败");
                /**
                 *1. 判断ip是否受限：是否是常用的ip地址（常用的ip地址不止一个）
                 *2. request.getRemoteAddr() 获取远程ip
                 *3. 比较是否属于常用ip地址
                 */
               
            }else if (!user.getAllowIps().contains( request.getRemoteAddr())){
//                不属于常用ip,不用需登录
                object.setCode(Constant.RETURN_OBJECT_CODE_FAIL);
                object.setMessage("ip地址异常，登录失败");
            }else{
//                信息合格可以登录
                object.setCode(Constant.RETURN_OBJECT_CODE_SUCCESS);

                /*
                 1.将数据保存在session中，session的作用范围是当前浏览器（多次请求），
                 2.保存用户信息，只要用户登录，在浏览器中的其他请求也是当前用户信息
               */
                session.setAttribute(Constant.SESSION_USER,user);//这里的key不要定死，可以设置常量

                /**
                * 1.用cookie实现记住密码功能（cookie在整个项目中都可以携带数据）
                * 2.判断是否选中记住我，如果状态为选中，那就添加cookie存值
                * 3.设置两个cookie，一个存姓名一个存密码，
                */
                if ("true".equals(isRemPwd)){
//                  设置cookie存用户名
                    Cookie c1 = new Cookie("loginAct", user.getLoginAct());
//                  设置cookie的有效期（单位是秒转为天）
                    c1.setMaxAge(10*24*60*60);
//                  因为要将记住的密码账号显示到页面，所以用response响应
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd", user.getLoginPwd());
                    c2.setMaxAge(10*24*60*60);
                    response.addCookie(c2);
                }else {
                    /**
                     * 1.如果用户第一天设置了记住密码，第二天取消记住密码功能，但是在cookie 的有效期内会一直记住密码
                     * 这就要删除cookie的信息，才能使记住功能失效，但是不能直接操作用户电脑删除cookie
                     * 所以可以通过重写cookie，覆盖原有的cookie信息，达到删除cookie的效果
                     * 2.覆盖cookie，要求设置与之前记住密码的cookie相同的key名,value随意
                     * 3.设置cookie的有效期为0，说明这个cookie实际上是一直失效的
                     * 4.如果用户没有记住密码，这个cookie的有效期为0，实际上cookie也是不存在，相当于没有记住我
                     * */
                    Cookie c1 = new Cookie("loginAct", "1");
                    c1.setMaxAge(0);
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd", "1");
                    c2.setMaxAge(0);
                    response.addCookie(c2);

                    }
                }
            }
            return object;
        }

                /**
                 *实现安全退出功能
                 * 1.清空cookie，销毁session
                 * 2.跳转到登录页面
                 * 3.从首页跳转到登录页面，使用重定向跳转改变当前页面的地址， 方便用户刷新登录页面
                 */

                @RequestMapping("/settings/qx/user/logout.do")
               public String logout(HttpServletResponse response,HttpSession session){
//                  清空cookie
                    Cookie c1 = new Cookie("loginAct", "1");
                    c1.setMaxAge(0);
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd", "1");
                    c2.setMaxAge(0);
                    response.addCookie(c2);
//                    销毁session
                    session.invalidate();
//                    跳转到首页，首页跳转登录页面
                    return "redirect:/";
                }
}
