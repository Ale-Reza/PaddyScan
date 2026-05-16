"""
Test detection model loading
"""

from detection_loader import initialize_detection_model, get_detection_loader
from pathlib import Path

def test_detection():
    """Test detection model loading"""
    
    print("=" * 60)
    print("🔍 Testing Detection Model")
    print("=" * 60)
    
    model_path = Path("models/detection_model.pt")
    
    if not model_path.exists():
        print(f"❌ Model not found at: {model_path}")
        return
    
    print(f"✅ Model file found: {model_path}")
    print(f"📏 File size: {model_path.stat().st_size / (1024*1024):.2f} MB")
    
    # Try to load
    success = initialize_detection_model(str(model_path))
    
    if success:
        print("\n✅ Detection model loaded successfully!")
        
        # Get loader
        loader = get_detection_loader()
        
        # Print model info - use attributes that exist in your DetectionLoader class
        print(f"   • Device: {loader.device}")
        print(f"   • Classes loaded: {len(loader.class_names) if hasattr(loader, 'class_names') else 'Unknown'}")
        
        # Print class names if available
        if hasattr(loader, 'class_names') and loader.class_names:
            print(f"\n   📋 Classes detected:")
            for idx, name in loader.class_names.items():
                print(f"      - {idx}: {name}")
        
        # Test with a sample image if available
        test_image = Path("./uploads/test_image.jpg")
        if test_image.exists():
            print(f"\n🔄 Testing detection on {test_image}...")
            detections, _ = loader.detect(str(test_image))
            print(f"   Found {len(detections)} detections")
            for i, det in enumerate(detections[:5]):  # Show first 5
                print(f"   • Detection {i+1}: {det.get('class_name', 'Unknown')} - {det['confidence']:.2f}")
        else:
            print(f"\n⚠️  No test image found. Create a test_leaf.jpg to test detection.")
    else:
        print("\n❌ Failed to load detection model")

if __name__ == "__main__":
    test_detection()