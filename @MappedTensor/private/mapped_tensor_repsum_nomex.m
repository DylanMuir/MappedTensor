function [vfDest] = mapped_tensor_repsum_nomex(vfSourceA, vfSourceB)
    [mfA, mfB] = meshgrid(vfSourceB, vfSourceA);
    vfDest = mfA(:) + mfB(:);
end
