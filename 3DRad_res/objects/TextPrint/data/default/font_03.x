xof 0303txt 0032
template VertexDuplicationIndices {
 <b8d65549-d7c9-4995-89cf-53a9a8b031e3>
 DWORD nIndices;
 DWORD nOriginalVertices;
 array DWORD indices[nIndices];
}

template FVFData {
 <b6e70a0e-8ef9-4e83-94ad-ecc8b0c04897>
 DWORD dwFVF;
 DWORD nDWords;
 array DWORD data[nDWords];
}


Frame FR00 {
 

 FrameTransformMatrix {
  1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000;;
 }

 Frame FR01 {
  

  FrameTransformMatrix {
   1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,0.000000,1.000000;;
  }

  Mesh {
   4;
   0.000000;1.000000;0.000000;,
   0.000000;-1.000000;0.000000;,
   1.000000;1.000000;0.000000;,
   1.000000;-1.000000;0.000000;;
   2;
   3;1,0,2;,
   3;1,2,3;;

   MeshNormals {
    4;
    0.000000;0.000000;-1.000000;,
    0.000000;0.000000;-1.000000;,
    0.000000;0.000000;-1.000000;,
    0.000000;0.000000;-1.000000;;
    2;
    3;1,0,2;,
    3;1,2,3;;
   }

   MeshTextureCoords {
    4;
    0.187500;0.000000;,
    0.187500;0.125000;,
    0.250000;0.000000;,
    0.250000;0.125000;;
   }

   MeshMaterialList {
    1;
    2;
    0,
    0;

    Material {
     1.000000;1.000000;1.000000;1.000000;;
     50.000000;
     0.000000;0.000000;0.000000;;
     0.000000;0.000000;0.000000;;

     TextureFilename {
      "fonts.dds";
     }
    }
   }

   VertexDuplicationIndices {
    4;
    4;
    0,
    1,
    2,
    3;
   }
  }
 }
}