# # """
# # Test PyTorch detection model
# # """

# # import requests
# # import json
# # from pathlib import Path

# # BASE_URL = "http://localhost:5000"
# # TEST_IMAGE = "uploads/test_image.jfif"# Your test image

# # def test_all_modes():
# #     """Test all three modes with PyTorch detection"""
    
# #     if not Path(TEST_IMAGE).exists():
# #         print(f"❌ Test image not found: {TEST_IMAGE}")
# #         return
    
# #     print("=" * 60)
# #     print("🧪 TESTING PADDYSCAN WITH PYTHORCH DETECTION")
# #     print("=" * 60)
    
# #     with open(TEST_IMAGE, 'rb') as f:
# #         files = {'image': f}
        
# #         # Test classification
# #         print("\n1️⃣ TESTING CLASSIFICATION ONLY")
# #         print("-" * 40)
# #         resp = requests.post(f"{BASE_URL}/api/classify", files=files)
# #         if resp.status_code == 200:
# #             data = resp.json()
# #             print(f"✅ Success!")
# #             print(f"   Disease: {data['results']['primary_diagnosis']['disease']}")
# #             print(f"   Confidence: {data['results']['primary_diagnosis']['confidence']:.3f}")
# #         else:
# #             print(f"❌ Failed: {resp.text}")
        
# #         f.seek(0)
        
# #         # Test detection
# #         print("\n2️⃣ TESTING DETECTION ONLY")
# #         print("-" * 40)
# #         resp = requests.post(f"{BASE_URL}/api/detect", files=files)
# #         if resp.status_code == 200:
# #             data = resp.json()
# #             print(f"✅ Success!")
# #             print(f"   Areas detected: {data['results']['affected_areas']}")
# #             print(f"   Severity: {data['results']['statistics']['severity']}")
# #             print(f"   Preview: {BASE_URL}{data['results'].get('preview_url', '')}")
# #         else:
# #             print(f"❌ Failed: {resp.text}")
        
# #         f.seek(0)
        
# #         # Test full diagnosis
# #         print("\n3️⃣ TESTING FULL DIAGNOSIS")
# #         print("-" * 40)
# #         resp = requests.post(f"{BASE_URL}/api/diagnose", files=files)
# #         if resp.status_code == 200:
# #             data = resp.json()
# #             print(f"✅ Success!")
# #             print(f"   Total areas: {data['results']['total_affected_areas']}")
# #             for d in data['results']['diseases_detected']:
# #                 print(f"   • {d['disease']}: {d['occurrences']} spots ({d['percentage']}%)")
# #         else:
# #             print(f"❌ Failed: {resp.text}")

# # if __name__ == "__main__":
# #     test_all_modes()


# import requests
# from pathlib import Path

# # Configuration
# BASE_URL = "http://localhost:5000"
# UPLOADS_DIR = Path("uploads")

# def run_batch_classification():
#     """Classifies 10 images and prints results to CMD"""
    
#     print("=" * 60)
#     print("🌾 PADDYSCAN: BATCH CLASSIFICATION TEST")
#     print("=" * 60)
#     print(f"{'IMAGE NAME':<20} | {'DISEASE':<20} | {'CONFIDENCE':<10}")
#     print("-" * 60)

#     for i in range(1, 11):
#         image_name = f"{i}.jfif"
#         image_path = UPLOADS_DIR / image_name

#         if not image_path.exists():
#             print(f"{image_name:<20} | ❌ File Not Found")
#             continue

#         try:
#             with open(image_path, 'rb') as f:
#                 files = {'image': f}
                
#                 # Using the specific classification endpoint
#                 resp = requests.post(f"{BASE_URL}/api/diagnose", files=files)
                
#                 if resp.status_code == 200:
#                     data = resp.json()
#                     # Navigating the JSON structure based on your backend output
#                     diag = data['results']['primary_diagnosis']
                    
#                     disease = diag['disease']
#                     conf = diag['confidence']
                    
#                     print(f"{image_name:<20} | {disease:<20} | {conf:.2%}")
#                 else:
#                     print(f"{image_name:<20} | ❌ Server Error: {resp.status_code}")
        
#         except Exception as e:
#             print(f"{image_name:<20} | 💥 Connection Error")

#     print("=" * 60)
#     print("🏁 CLASSIFICATION COMPLETE")

# if __name__ == "__main__":
#     run_batch_classification()

#         image_name = f"{i}.jfif"
#         image_path = UPLOADS_DIR / image_name
# BASE_URL = "http://localhost:5000"
# UPLOADS_DIR = Path("uploads")
import requests
from pathlib import Path

# Configuration
import os
import cv2
import numpy as np
from pathlib import Path

# Assuming your predictor is in modular_predictor.py
from modular_predictor import get_predictor

def run_batch_diagnosis():
    # --- CONFIGURATION ---
    # Update these paths to your actual model files
    CLASSIFICATION_MODEL = "models/classification_model.h5"
    DETECTION_MODEL = "models/detection_model.pt"
    TEST_IMAGE_DIR = "uploads/"  # Folder containing 1.jfif, 2.jfif, etc.
    
    # Initialize the predictor
    predictor = get_predictor(CLASSIFICATION_MODEL, DETECTION_MODEL)
    
    print("=" * 75)
    print("🌾 PADDYSCAN: FULL DIAGNOSIS BATCH TEST (YOLO + TENSORFLOW)")
    print("=" * 75)
    print(f"{'IMAGE':<15} | {'DISEASE':<20} | {'CONF':<8} | {'SPOTS':<5} | {'STATUS'}")
    print("-" * 75)

    # Get all images from directory
    image_extensions = ('.jfif')
    image_paths = [p for p in Path(TEST_IMAGE_DIR).glob('*') if p.suffix.lower() in image_extensions]
    
    if not image_paths:
        print(f"❌ No images found in {TEST_IMAGE_DIR}")
        return

    for img_path in sorted(image_paths, key=lambda x: x.name):
        image_name = img_path.name
        
        try:
            # Run the full diagnosis mode
            # This detects spots with YOLO, then classifies each crop with TF
            result = predictor.full_diagnosis(str(img_path))
            
            if "error" in result:
                print(f"{image_name:<15} | Error: {result['error'][:18]:<13} | ---      | ---   | ❌ FAIL")
                continue

            # --- DATA EXTRACTION (Updated for new structure) ---
            # Extract primary disease info
            primary = result.get('primary_disease')
            if primary:
                disease_name = primary.get('name', 'Unknown')
                confidence = primary.get('confidence', 0.0)
            else:
                # If YOLO found 0 spots, it's likely a healthy leaf
                disease_name = "Healthy/No Spots"
                confidence = 0.0

            # Get the count of detected spots
            spot_count = result.get('total_affected_areas', 0)
            
            # Format output
            # disease_name is limited to 20 chars for table alignment
            disp_disease = (disease_name[:17] + '..') if len(disease_name) > 20 else disease_name
            
            print(f"{image_name:<15} | {disp_disease:<20} | {confidence:<8.2%} | {spot_count:<5} | ✅ OK")

        except Exception as e:
            print(f"{image_name:<15} | Exception occurred    | ---      | ---   | ❌ CRASH")
            # print(f"Error detail: {e}") # Uncomment for debugging

    print("=" * 75)
    print(f"🏁 FULL DIAGNOSIS TEST COMPLETE: {len(image_paths)} IMAGES PROCESSED")
    print("=" * 75)

if __name__ == "__main__":
    # Ensure the 'processed' directory exists for result images
    Path("processed").mkdir(exist_ok=True)
    run_batch_diagnosis()