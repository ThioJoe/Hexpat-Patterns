#pragma description exFAT boot sector and BIOS parameter block (BPB)

#pragma MIME application/x-exfat-bootsector

import std.core;
import std.mem;

bitfield VolumeFlags {
    activeFat : 1 [[name("Active FAT")]];
    volumeDirty : 1 [[name("Volume Dirty")]];
    mediaFailure : 1 [[name("Media Failure")]];
    clearToZero : 1 [[name("Clear to Zero")]];
    reserved : 4 [[name("Reserved")]];
};

struct ExfatBiosParameterBlock {
    u64 partitionOffset [[name("Partition Offset")]];
    u64 totalSectors [[name("Total Sectors in Volume")]];
    u32 fatOffset [[name("FAT Offset (Offset of First FAT)")]];
    u32 fatLength [[name("FAT Length (in sectors)")]];
    u32 clusterHeapOffset [[name("Cluster Heap Offset")]];
    u32 clusterCount [[name("Cluster Count")]];
    u32 rootDirectoryFirstCluster [[name("Root Directory First Cluster")]];
    u32 volumeSerialNumber [[name("Volume Serial Number")]];
    u16 fileSystemRevision [[name("File System Revision (MM.VV)")]];
    VolumeFlags volumeFlags [[inline]];
    u8 bytesPerSectorShift [[name("Bytes Per Sector Shift")]];
    u8 sectorsPerClusterShift [[name("Sectors Per Cluster Shift")]];
    u8 numberOfFats [[name("Number of FATs")]];
    u8 driveSelect [[name("Drive Select (Hex)")]];
    u8 percentInUse [[name("Percent in Use")]];
};

struct BootSector {
    u8 instruction[3] [[name("JMP instruction")]];
    char name[8] [[name("OEM")]];
    u8 reserved1[53];
    ExfatBiosParameterBlock bpb @ 0x40;
    u8 reserved2[390];
    u16 signature @ 0x1FE [[name("Signature (55 AA)")]];
};

BootSector bootSector @ 0x00;

struct ExtendedBootSector {
    u8 extBootCode[508];
    u32 extBootSignature;
};

ExtendedBootSector extendedBootSectors[8] @ 512;

u8 oemParameters[512] @ 4608; // 9 * 512

u32 bootChecksum[128] @ 5632; // 11 * 512
