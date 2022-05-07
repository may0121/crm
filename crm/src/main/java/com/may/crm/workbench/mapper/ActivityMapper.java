package com.may.crm.workbench.mapper;

import com.may.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity
     *
     * @mbggenerated Thu Apr 28 14:56:52 CST 2022
     */
    int deleteByPrimaryKey(String id);


    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity
     *
     * @mbggenerated Thu Apr 28 14:56:52 CST 2022
     */
    int insertSelective(Activity record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity
     *
     * @mbggenerated Thu Apr 28 14:56:52 CST 2022
     */
    Activity selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity
     *
     * @mbggenerated Thu Apr 28 14:56:52 CST 2022
     */
    int updateByPrimaryKeySelective(Activity record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_activity
     *
     * @mbggenerated Thu Apr 28 14:56:52 CST 2022
     */
    int updateByPrimaryKey(Activity record);


    /**
     * 新增添加的市场活动
     * @param activity 创建的市场活动
     * @return 插入数据的条数
     */
    int insertActivity(Activity activity);

        /**
         *按条件分页查询数据
         * @param  map 查询条件
         * @return 查询的数据
         */
    List<Activity> selectActivityByConditionForPage(Map<String,Object> map);

         /**
         * 查询符合条件活动总条数
         * @param map 查询的条件
         * @return int 总数
         */
    int selectCountOfActivityByCondition(Map<String,Object> map);

    /**
     * 按id删除市场活动
     * @param ids id号（可以批量删除）
     * @return
     */
    int deleteActivityByIds(String [] ids);

    /**
     * 根据id修改市场活动信息(先查询之前原有的信息)
     * @param id 号
     * @return
     */
    Activity queryActivityById(String id);

    /**
     * 根据id修改市场活动信息之后并保存在模态窗口
     * @param activity 要修改的活动信息
     * @return int 修改的条数
     */
  int updateActivityById(Activity activity);

  /**
   * 查询所有市场市场活动信息（批量导出文件）
   * @param
   * @return 查询到的活动
   */
  List<Activity> queryAllActivities();

  /**
   * 选择部分异常活动
   * @param
   * @return
   */
  List<Activity> queryCheckedActivity(String [] id);

  /**
   * 批量导入文件
   * @param
   * @return
   */
  int insertActivitiesByList (List<Activity> activityList);
 /**
  * 根据id 查询市场活动详情
  * @param
  * @return
  */
 Activity selectActivityForDetailById(String id);
}