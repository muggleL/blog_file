---
title: 🤖️Android-Tips
date: '2020-11-30'
author: DG
tags: 
- 编程
- 代码
categories: 
- Android
slug: android-tips
---


##   `Activity` 绑定 `Fragment`

```java
public stativ void main() {
  
}
```



##  `Fragment`   跳转到   `Activity`

1. 在 `Fragment` 配置跳转和跳转参数

```java
Intent intent = new Intent(getActivity(), HomeActivity.class);
Bundle bundle = new Bundle();
bundle.putSerializable("pageFlag", homePageWidgets.get(position).getFlag()); // 装载可以序列化的类型
bundle.putInt("title", homePageWidgets.get(position).getNameId()); // 装载 int
intent.putExtras(bundle);
startActivity(intent);
```
2. 在 `Activity` 中接收跳转参数

```java
Intent intent = getIntent();
Bundle bundle = intent.getExtras();
PageFlag PageFlag = (PageFlag) bundle.getSerializable("pageFlag");
int title = bundle.getInt("title");
```

## `GridView` 使用

1. `layout` 中添加 `GridView` 标签
```xml
<GridView
          android:id="@+id/grid_view_account"
          android:layout_marginTop="10dp"
          android:layout_width="wrap_content"
          android:layout_height="wrap_content"
          tools:listitem="@layout/item_account_grid_view"/> <!--指定 item 的布局文件-->
```
2. 增加 `Item` 的布局文件
```java
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="80dp">

        <ImageView
            android:id="@+id/item_img"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:layout_marginStart="15dp"
            android:src="@drawable/ic_baseline_cloud_upload_24" />

        <TextView
            android:id="@+id/item_text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:layout_marginStart="20dp"
            android:text="@string/version_update"
            android:textSize="18sp"
            android:textColor="@color/text_color"/>
    </LinearLayout>
    <TextView
        android:layout_width="match_parent"
        android:layout_height=".5dp"
        android:background="@color/under_line_color"
        android:layout_alignParentBottom="true"/>
    <ImageView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center_vertical"
        android:layout_marginEnd="18dp"
        android:layout_alignParentEnd="true"
        android:layout_centerVertical="true"
        android:src="@drawable/ic_baseline_arrow_forward_ios_24" />
</RelativeLayout>
```
3. 在页面中给 Item 写入数据并启动

```java
 // grid View
List<HomePageWidget> homePageWidgets = new ArrayList<>();
homePageWidgets.add(new HomePageWidget(R.drawable.ic_baseline_cloud_upload_24, R.string.version_update, PageFlag.UPDATE));
homePageWidgets.add(new HomePageWidget(R.drawable.ic_baseline_message_24, R.string.feedback, PageFlag.FEED_BACK));
homePageWidgets.add(new HomePageWidget(R.drawable.ic_baseline_phonelink_ring_24, R.string.contact, PageFlag.CONTACT));
GridView gridView = root.findViewById(R.id.grid_view_account);
gridView.setAdapter(new HomePageAdapter(homePageWidgets, getContext(), R.layout.item_account_grid_view));

// 监听 Item 的点击事件
gridView.setOnItemClickListener((parent, view, position, id) -> {
  Toast toast = Toast.makeText(getContext(), "你點擊了：" + homePageWidgets.get(position).getFlag(), Toast.LENGTH_SHORT);
  toast.setGravity(GridView.TEXT_ALIGNMENT_CENTER, 0, 0);
  toast.show();
  System.out.println(homePageWidgets.get(position).getFlag());
});
```

4. 效果

![screenshot.png](https://i.loli.net/2020/11/28/wGCE2OtXzaYMJbV.jpg)




## `CardView`



## 自定义 `Zxing` 样式/添加闪光灯按钮/开启竖屏扫码支持
1. 导入 `Zxing` 依赖

```groovy
implementation 'com.journeyapps:zxing-android-embedded:4.1.0' 
```

2. 自定义扫码页面布局

```xml
<!-- activity_zxing.xml-->
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".ui.scan.MyCaptureActivity">

    <com.journeyapps.barcodescanner.DecoratedBarcodeView
        android:id="@+id/zxing_barcode_scanner"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:zxing_scanner_layout="@layout/custom_barcode_scanner" /> <!-- 指定扫码界面布局-->

  <!-- 返回按钮 -->
    <ImageButton
        android:layout_width="30dp"
        android:layout_height="30dp"
        android:background="@color/transparent"
        android:src="@drawable/ic_arrow_back_24"
        android:layout_alignParentTop="true"
        android:layout_marginStart="20dp"
        android:layout_marginTop="30dp"
        android:onClick="activityBack"/>

  <!-- 闪关灯开关按钮-->
    <ImageButton
        android:id="@+id/switch_flashlight"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentBottom="true"
        android:layout_centerHorizontal="true"
        android:layout_marginBottom="80dp"
        android:background="@color/transparent"
        android:onClick="switchFlashlight"
        android:src="@drawable/ic_iconmonstr_light_off_17" />
```

3. 自定义扫描界面布局

```xml
<!-- custom_barcode_scanner.xml -->
<?xml version="1.0" encoding="utf-8"?>
<merge xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <com.journeyapps.barcodescanner.BarcodeView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:id="@+id/zxing_barcode_surface"/>

    <com.journeyapps.barcodescanner.ViewfinderView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:id="@+id/zxing_viewfinder_view"
        app:zxing_possible_result_points="@color/button"
        app:zxing_result_view="@color/zxing_custom_result_view"
        app:zxing_viewfinder_laser="@color/main_color" 
        app:zxing_viewfinder_laser_visibility="true"
        app:zxing_viewfinder_mask="@color/zxing_custom_viewfinder_mask"/>

    <TextView
        android:id="@+id/zxing_status_view"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal"
        android:background="@color/transparent"
        android:text="@string/zxing_msg_status"
        android:textColor="@color/zxing_status_text"/>

</merge>
```

4. 自定义扫码方法

```java
// MyCaptureActivity
// DecoratedBarcodeView.TorchListener 闪光灯控制接口
public class MyCaptureActivity extends Activity implements DecoratedBarcodeView.TorchListener {
    private CaptureManager capture;
    private DecoratedBarcodeView barcodeScannerView;
    private ImageButton switchFlashlightButton;
    private ViewfinderView viewfinderView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_zxing); // 指定扫码界面布局
        barcodeScannerView = findViewById(R.id.zxing_barcode_scanner);
        barcodeScannerView.setTorchListener(this);
        switchFlashlightButton = findViewById(R.id.switch_flashlight);
        switchFlashlightButton.setTag(R.string.tag_off); //给按钮设置 Tag 判断闪光灯的开关状态 默认为 off
        viewfinderView = findViewById(R.id.zxing_viewfinder_view);
        viewfinderView.setLaserVisibility(true);

        // remove button when devices have no flashlight
        if (!hasFlash()) {
            switchFlashlightButton.setVisibility(View.GONE);
        }

        capture = new CaptureManager(this, barcodeScannerView);
        capture.initializeFromIntent(getIntent(), savedInstanceState);
        capture.setShowMissingCameraPermissionDialog(false);
        capture.decode();

//        viewfinderView.setMaskColor(Color.argb(100, 15, 194, 76));
    }
  
    @Override
    protected void onResume() {
        super.onResume();
        capture.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        capture.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        capture.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        capture.onSaveInstanceState(outState);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        capture.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return barcodeScannerView.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
    }

    @Override
    public void onTorchOn() {
        switchFlashlightButton.setImageResource(R.drawable.ic_iconmonstr_light_on_17);
        switchFlashlightButton.setTag(R.string.tag_on); // 闪光灯开 修改 tag 状态
    }

    @Override
    public void onTorchOff() {
        switchFlashlightButton.setImageResource(R.drawable.ic_iconmonstr_light_off_17);
        switchFlashlightButton.setTag(R.string.tag_off);// 闪光灯关 修改 tag 状态
    }

    // 判斷是否有閃光燈
    private boolean hasFlash() {
        return getApplicationContext().getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
    }

    // 閃光燈控制
    public void switchFlashlight(View view) {
      // 根据tag 判断闪光灯开关状态
        if ((int)switchFlashlightButton.getTag() == R.string.tag_off) {
            barcodeScannerView.setTorchOn();
        } else {
            barcodeScannerView.setTorchOff();
        }
    }

    // 返回
    public void activityBack(View view) {
        this.finish();
    }
}

```

5. 使用自定义 `activity`

- 在 `Activity` 中

```java
public class ScanActivity extends AppCompatActivity {
    private TextView textView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
      
        ...

        IntentIntegrator intentIntegrator = new IntentIntegrator((this));
        intentIntegrator.setCaptureActivity(MyCaptureActivity.class);
        intentIntegrator.setOrientationLocked(false); // 开启竖屏扫码支持
        intentIntegrator.initiateScan();
    }

    // 重写方法接收结果
    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
        if (result != null) {
            if (result.getContents() == null) {
                textView.setText(R.string.scan_error);
            } else {
                textView.setText(result.getContents());
                System.out.println(result.getContents());
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }
  ...
}
```

- 在 `Fragment` 中

```java
IntentIntegrator intentIntegrator = IntentIntegrator.forSupportFragment(this);
intentIntegrator.setCaptureActivity(MyCaptureActivity.class);
intentIntegrator.setOrientationLocked(false);
intentIntegrator.initiateScan();

// 然后重写 onActivityResult 方法接受参数
```

6. 效果

![screenshot.png](https://i.loli.net/2020/11/28/Jn8iyz1SEd47vkN.jpg)



## 绝对布局与线性布局



## 圆角与阴影



## 自定义 `ActionBar`

1. 页面布局

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="?attr/actionBarSize">


    <ImageButton
        android:id="@+id/icon_back"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentStart="true"
        android:layout_centerVertical="true"
        android:src="@drawable/ic_arrow_back_24"
        android:background="@color/transparent"
        android:onClick="activityBack"/>

    <TextView
        android:id="@+id/action_bar_ti"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:text="@string/title_home"
        android:textColor="@color/white"
        android:textSize="18sp" />

    <ImageButton
        android:id="@+id/icon_qr"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentEnd="true"
        android:layout_centerVertical="true"
        android:background="@color/transparent"
        android:src="@drawable/ic_baseline_qr_code_24"
        android:onClick="qrScan"/>
</RelativeLayout>
```

2. 在 `Activity` 中开启自定义支持，并指定布局

```java
Objects.requireNonNull(getSupportActionBar()).setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
getSupportActionBar().setCustomView(R.layout.style_action_bar_page);
TextView view = findViewById(R.id.action_bar_ti);
view.setText(title)
```

3. 效果

![2.png](https://i.loli.net/2020/11/28/7VoCYB3vDQUPqZp.jpg)


## `Okhttp3` 与 `Retrofit`



```

```