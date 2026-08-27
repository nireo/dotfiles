" Metal Shading Language extends C++14 with GPU stages, address spaces,
" resource types, and [[attribute]] annotations.
runtime! syntax/cpp.vim

syntax keyword metalStage kernel vertex fragment visible intersection mesh object
syntax keyword metalAddressSpace device constant thread threadgroup threadgroup_imageblock
syntax keyword metalAddressSpace ray_data object_data
syntax keyword metalQualifier packed precise
syntax keyword metalResource sampler texture1d texture1d_array texture2d texture2d_array
syntax keyword metalResource texture2d_ms texture2d_ms_array texture3d texturecube
syntax keyword metalResource texturecube_array depth2d depth2d_array depth2d_ms
syntax keyword metalResource depthcube depthcube_array acceleration_structure intersection_function_table
syntax keyword metalResource visible_function_table primitive_acceleration_structure
syntax keyword metalResource instance_acceleration_structure

syntax region metalAttribute start=/\[\[/ end=/\]\]/ contains=metalAttributeName,metalAttributeNumber
syntax keyword metalAttributeName contained stage_in position point_size clip_distance color depth
syntax keyword metalAttributeName contained buffer texture sampler function_constant
syntax keyword metalAttributeName contained vertex_id instance_id base_vertex base_instance
syntax keyword metalAttributeName contained thread_position_in_grid threadgroup_position_in_grid
syntax keyword metalAttributeName contained threads_per_threadgroup thread_index_in_threadgroup
syntax keyword metalAttributeName contained thread_position_in_threadgroup grid_origin grid_size
syntax keyword metalAttributeName contained sample_id sample_mask primitive_id front_facing
syntax keyword metalAttributeName contained center_perspective centroid_perspective sample_perspective
syntax keyword metalAttributeName contained center_no_perspective centroid_no_perspective sample_no_perspective flat
syntax match metalAttributeNumber contained /\d\+/

highlight default link metalStage Keyword
highlight default link metalAddressSpace StorageClass
highlight default link metalQualifier Type
highlight default link metalResource Type
highlight default link metalAttribute PreProc
highlight default link metalAttributeName Special
highlight default link metalAttributeNumber Number

let b:current_syntax = "metal"
