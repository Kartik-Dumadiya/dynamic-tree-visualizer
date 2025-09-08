# Dynamic Tree Visualizer - Image Asset Instructions

## 🖼️ How to Add Your Custom Images

Your Flutter app is now configured to display large, responsive images in the application examples popup. Here's how to add your custom images:

### 📁 Folder Structure

Your app now has the following assets structure:
```
dynamic_tree_visualizer/
├── assets/
│   └── images/
│       ├── org_chart.png           (your organizational chart image)
│       ├── file_system.png         (your file system tree image)
│       ├── mind_map.png            (your mind mapping image)
│       ├── decision_tree.png       (your AI/ML decision tree image)
│       ├── dom_tree.png            (your DOM structure image)
│       └── network_topology.png    (your network diagram image)
├── lib/
├── pubspec.yaml
└── ...
```

### 🎯 Step-by-Step Instructions

1. **Navigate to the Assets Folder**
   - Go to: `c:\Users\Kartik\Desktop\testing\dynamic_tree_visualizer\assets\images\`

2. **Replace Placeholder Files**
   - Delete the `.placeholder.txt` files
   - Add your actual image files with these exact names:
     - `org_chart.png`
     - `file_system.png`
     - `mind_map.png`
     - `decision_tree.png`
     - `dom_tree.png`
     - `network_topology.png`

3. **Image Requirements**
   - **Formats Supported**: PNG, JPG, GIF, WebP
   - **Recommended Size**: 500x300 pixels (or similar aspect ratio)
   - **File Size**: Keep under 2MB for good performance
   - **Naming**: Must match the exact filenames listed above

4. **After Adding Images**
   - Run `flutter pub get` in your terminal
   - Hot reload or restart your app
   - Images will automatically appear in the applications popup

### 📱 Responsive Behavior

Your images will automatically adapt to different screen sizes:

- **Desktop (> 600px width)**: 
  - Large images (45% of dialog width)
  - Images appear on the left side
  - Text content on the right side

- **Mobile (≤ 600px width)**:
  - Small images (80x80 pixels)
  - Images appear in the top-right corner
  - Text content flows below

### 🔧 How to Add More Examples

To add new application examples:

1. **Add New Images**
   - Place your new images in `assets/images/`
   - Use descriptive filenames (e.g., `my_new_app.png`)

2. **Update the Data**
   - Open `lib/utils/constants.dart`
   - Find the `AppExamples.examples` list (around line 279)
   - Add a new `AppExample`:
   ```dart
   AppExample(
     title: "Your New Application",
     description: "Description of your new tree visualization use case.",
     imagePath: "assets/images/my_new_app.png",
     features: [
       "Feature 1",
       "Feature 2",
       "Feature 3",
       "Feature 4"
     ],
   ),
   ```

3. **Restart Your App**
   - Your new example will appear in the applications popup

### 🎨 Image Tips

- **High Quality**: Use clear, high-resolution images
- **Consistent Style**: Keep a consistent visual style across all images
- **Dark Theme Friendly**: Consider how images look against dark backgrounds
- **Tree Focus**: Images showing tree-like structures work best
- **Professional Look**: Use clean, professional-looking diagrams

### 🚀 Current Features

Your app now includes:
- ✅ Responsive image sizing
- ✅ Professional dark theme popup
- ✅ Smooth sliding animations
- ✅ Horizontal layout for desktop
- ✅ Compact mobile layout
- ✅ Error handling for missing images
- ✅ Asset integration ready

### 🔍 Troubleshooting

**If images don't appear:**
1. Check file names match exactly (case-sensitive)
2. Ensure images are in the correct folder
3. Run `flutter pub get`
4. Restart the app completely
5. Check the file formats are supported

**If layout looks wrong:**
1. Check image aspect ratios (16:10 or 3:2 recommended)
2. Ensure images aren't too large (> 5MB)
3. Test on both desktop and mobile sizes

### 📞 Need Help?

If you encounter any issues:
1. Check the Flutter console for error messages
2. Verify your `pubspec.yaml` includes the assets section
3. Make sure all image files exist and aren't corrupted

Your tree visualizer is now ready for professional use with custom images! 🎉
