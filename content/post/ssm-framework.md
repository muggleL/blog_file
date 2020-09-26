---
title: 🦉SMM 框架整合
date: '2019-10-25'
slug: ssm-framework
author: DG
tags: 
  - 编程
  - 代码
categories: 
  - Java
---

## xml 模式

### 1. web.xml 启动spring、springMVC

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
    http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd">

  <display-name>Archetype Created Web Application</display-name>

  <!-- 过滤器 解决中文乱码-->
  <filter>
    <filter-name>characterEncodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
      <param-name>encoding</param-name>
      <param-value>UTF-8</param-value>
    </init-param>
  </filter>
  <filter-mapping>
    <filter-name>characterEncodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>
    
  <!--监听器 启动 Spring-->
  <listener>
    <!--加载 spring 默认只加载 WEB-INF 目录下的文件-->
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
  </listener>
  <!--  设置配置文件路径-->
  <context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:applicationContext.xml</param-value>
  </context-param>

  <!--  前端控制器 启动 SpringMVC-->
  <servlet>
    <servlet-name>dispatcherServlet</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <!--  加载 springMVC 配置文件-->
    <init-param>
      <param-name>contextConfigLocation</param-name>
      <param-value>classpath:springMVC.xml</param-value>
    </init-param>
    <!--启动服务器创建该 servlet-->
    <load-on-startup>1</load-on-startup>
  </servlet>
    
  <servlet-mapping>
    <servlet-name>dispatcherServlet</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>
    
  <!--静态资源-->
  <servlet-mapping>
    <servlet-name>default</servlet-name>
    <url-pattern>/css/*</url-pattern>
    <url-pattern>/img/*</url-pattern>
    <url-pattern>/js/*</url-pattern>
    <url-pattern>/layui/*</url-pattern>
    <url-pattern>/plugin/*</url-pattern>
    <url-pattern>/ui/*</url-pattern>
    <url-pattern>/system/css/*</url-pattern>
    <url-pattern>/system/js/*</url-pattern>
  </servlet-mapping>

</web-app>
```



### 2. Spring 配置文件装载 Mybaties

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       http://www.springframework.org/schema/aop
       http://www.springframework.org/schema/aop/spring-aop.xsd
       http://www.springframework.org/schema/tx
       http://www.springframework.org/schema/tx/spring-tx.xsd">

    <!--开启扫描，只处理 service 和 dao -->
    <context:component-scan base-package="de.o0o0o0">
        <!--不扫描 controller 注解-->
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
    </context:component-scan>

<!--    整合 mybatis-->
    <!--连接池-->
    <!--c3p0-->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="user" value="${db.username}"/>
        <property name="driverClass" value="${db.driver}"/>
        <property name="password" value="${db.password}"/>
        <property name="jdbcUrl" value="${db.url}"/>
    </bean>
<!--数据源配置文件-->
    <context:property-placeholder location="classpath:db.properties"/>
    
    <!--SQLSessionFactory-->
    <bean id="sessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="mapperLocations">
            <list>
                <value>classpath:mapper/*.xml</value>
            </list>
        </property>
        <property name="typeAliasesPackage" value="de.o0o0o0.entity"/>
    </bean>
    
    <!--扫描的Dao-->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="sqlSessionFactoryBeanName" value="sessionFactory"/>
        <property name="basePackage" value="de.o0o0o0.dao"/>
    </bean>

    <!--事物管理器-->
    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>
    
    <!--事物 通知-->
    <tx:advice id="txAdvice" transaction-manager="transactionManager">
        <tx:attributes>
            <tx:method name="find*" read-only="true"/>
            <tx:method name="*" isolation="DEFAULT"/>
        </tx:attributes>
    </tx:advice>
    
    <!--aop 增强-->
    <aop:config>
        <aop:advisor advice-ref="txAdvice" pointcut="execution(* de.o0o0o0.service.impl.*ServiceImpl.*(..))"/>
    </aop:config>
</beans>
```

### 3.springMVC.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="
       http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/mvc
       http://www.springframework.org/schema/mvc/spring-mvc.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd">
    <!--    开启注解扫描-->
    
    <context:component-scan base-package="de.o0o0o0">
        <context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
    </context:component-scan>
    
    <!--配置试图解析器-->
    <bean id="internalResourceViewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
        <property name="prefix" value="/WEB-INF/pages/"/>
        <property name="suffix" value=".jsp"/>
    </bean>
    
    <!--过滤静态资源-->
    <mvc:default-servlet-handler/>
<!--    <mvc:resources location="/css/" mapping="/css/**"/>-->
<!--    <mvc:resources location="/img/" mapping="/img/**"/>-->
<!--    <mvc:resources location="/js/" mapping="/js/**"/>-->
<!--    <mvc:resources location="/layui/" mapping="/layui/**"/>-->
<!--    <mvc:resources location="/plugin/" mapping="/plugin/**"/>-->
<!--    <mvc:resources location="/ui/" mapping="/ui/**"/>-->
<!--    <mvc:resources location="/system/css/" mapping="/system/css/**"/>-->
<!--    <mvc:resources location="/system/js/" mapping="/system/js/**"/>-->
    <!--开启 SpringMVC 注解支持-->
    <mvc:annotation-driven/>
</beans>
```

## 纯注解模式

### 1. 实现`WebApplicationInitializer` 方法实现 对 `web.xml` 的功能

在这个方法中加载

```java
public class WebInitializer implements WebApplicationInitializer {
    public void onStartup(ServletContext servletContext) {
        //启动Spring
        AnnotationConfigWebApplicationContext ctx = new AnnotationConfigWebApplicationContext();
        // 注册  SpringMVC
        ctx.register(MyMVCConfig.class);
        // 过滤器 去除中文乱码
        servletContext.addFilter("encodingFilter", new CharacterEncodingFilter("UTF-8",true));
        
        ctx.setServletContext(servletContext);
        // 前端过滤器
        ServletRegistration.Dynamic servlet = servletContext.addServlet("dispatcher", new DispatcherServlet(ctx));
        servlet.addMapping("/");
        servlet.setLoadOnStartup(1);
    }
}
```

### 2. `MyMVCConfig` 继承`WebMvcConfigurerAdapter`代替  `spring-mvc.xml`

```java
@Configuration
@EnableWebMvc
@ComponentScan("de.o0o0o0")
// 失效
// @PropertySource(value = "classpath:jdbc.properties",encoding = "UTF-8")
public class MyMVCConfig extends WebMvcConfigurerAdapter {

    // 视图解析器
    @Bean
    public InternalResourceViewResolver viewResolver() {
        InternalResourceViewResolver viewResolver = new InternalResourceViewResolver();
        viewResolver.setPrefix("/WEB-INF/");
        viewResolver.setSuffix(".jsp");
        viewResolver.setViewClass(JstlView.class);
        return viewResolver;
    }

    // 静态文件过滤器
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        //两个*表示以/assets开始的任意层级的路径都可以访问得到图片，如<img src="../assets/img/1.png">
        //一个*表示只可以访问assets目录下的图片文件
        registry.addResourceHandler("/static/**").addResourceLocations("/static/");
    }
    

    // 连接池
    @Bean
    public BasicDataSource dataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://172.17.0.2:3306/blo?useUnicode=true&characterEncoding=UTF-8");
        dataSource.setUsername("root");
        dataSource.setPassword("12134");
//        dataSource.setInitialSize(initialSize);
//        dataSource.setMaxActive(maxActive);
//        dataSource.setMaxIdle(maxIdle);
//        dataSource.setMinIdle(minIdle);
//        dataSource.setMaxWait(maxWait);
        return dataSource;
    }

    // 装载 SqlSessionFactory
    @Bean
    public SqlSessionFactoryBean sqlSessionFactoryBean() {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        try {
            sqlSessionFactoryBean.setMapperLocations(resolver.getResources("classpath:mapping/*.xml"));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return sqlSessionFactoryBean;
    }

    // 为 SqlSessionFactory 配置扫描的包
    @Bean
    public MapperScannerConfigurer mapperScannerConfigurer() {
        MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
        mapperScannerConfigurer.setBasePackage("de.o0o0o0.dao");
        mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactoryBean");
        return mapperScannerConfigurer;
    }

    // 事物配置
    @Bean
    public DataSourceTransactionManager transactionManager() {
        DataSourceTransactionManager dataSourceTransactionManager = new DataSourceTransactionManager();
        dataSourceTransactionManager.setDataSource(dataSource());
        return dataSourceTransactionManager;
    }

    // 添加拦截器
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loginInterceptors());
    }

    @Bean
    public LoginInterceptors loginInterceptors() {
        return new LoginInterceptors();
    }

}
```

###  3. `LoginInterceptors` 实现 `HandlerInterceptor` 拦截器

登录拦截

```java
public class LoginInterceptors implements HandlerInterceptor {
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o) throws Exception {
        httpServletRequest.setCharacterEncoding("UTF-8");
        StringBuffer requestURL = httpServletRequest.getRequestURL();
        if (requestURL.toString().contains("DG")&&!requestURL.toString().contains("DG/login")&&!requestURL.toString().contains("DG/dologin")) {
            Object user = httpServletRequest.getSession().getAttribute("user");
            if (user == null) {
                httpServletResponse.sendRedirect("/DG/login");
                return false;
            } else {
                return true;
            }
        }else{
            return true;
        }
    }

    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) {
    }

    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) {
    }
}
```

