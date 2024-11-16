#pragma description FAT32 boot sector, BIOS parameter block (BPB) and more

#pragma MIME application/x-fat32-boot-sector

import std.core;
import std.mem;

struct BiosParameterBlock {
    u16 bytesPerSector;
    u8 sectorsPerCluster [[comment("In powers of 2")]];
    u16 reservedSectors [[comment("Usually 32 for FAT32")]];
    u8 numberOfFATs;
    u16 rootEntriesUnused [[comment("Not applicable for FAT32, should be 0")]];
    u16 sectorsSmallVolumes [[comment("Not applicable for FAT32, should be 0")]];
    u8 mediaDescriptor [[comment("0xF8 for hard disk")]];
    u16 sectorsPerFatSmallVolumes [[comment("Must be 0 for FAT32")]];
    u16 sectorsPerTrack;
    u16 heads;
    u32 hiddenSectors;
    u32 sectorsLargeVolumes [[comment("Total sectors in partition")]];
};

struct ExtendedFlags {
    u8 reserved [[comment("Must be 0x00")]];
    u8 flagByte;
};

bitfield FlagByte {
    activeFAT : 7 [[comment("The active FAT copy")]];
    fatMirroringDisabled : 1;
};

struct Fat32ParameterBlock {
    u32 sectorsPerFAT;
    ExtendedFlags extendedFlags [[inline]];
    u16 version [[comment("High byte: major, Low byte: minor")]];
    u32 rootDirFirstCluster;
    u16 fsInfoSector [[comment("Usually 1, relative to start of partition")]];
    u16 backupBootSector [[comment("Usually 6, relative to start of partition")]];
    u8 reserved[12];
};

struct DriveParameters {
    u8 biosDrive [[comment("Logical drive number of partition")]];
    u8 dirtyBit [[comment("0x41 indicates dirty volume, 0x00 indicates clean volume")]];
    u8 extBootSignature [[comment("Should be 0x29")]];
    u32 volumeSerialNumber;
    char volumeLabel[11];
    char fileSystem[8] [[comment("Usually 'FAT32'")]];
};

fn formatHex(u32 value) {
    return std::format("0x{:X}", value);
};

struct Fat32BootSector {
    u8 jmpInstruction[3] [[name("JMP instruction"), comment("Usually 0xEB 0x58 0x90")]];
    char oemName[8] [[name("OEM Name"), comment("e.g., 'MSWIN4.1' or 'mkdosfs'")]];

    BiosParameterBlock bpb [[name("BIOS Parameter Block")]];
    Fat32ParameterBlock fat32 [[name("FAT32 Parameter Block")]];

    DriveParameters driveParams [[name("Drive Parameters")]];
    u8 bootCode[420] [[name("Boot Code")]];

    u8 bootSignature[2] @ 0x1FE [[name("Boot Signature"), comment("Should be 0x55 0xAA")]];
};

Fat32BootSector bootSector @ 0x00;

// FSInfo Sector structure
struct FSInfoSector {
    u32 leadSignature @ 0x00 [[name("Lead Signature"), comment("Should be 0x52 0x52 0x61 0x41 ('RRaA')")]];
    u8 reserved1[480] @ 0x04;
    u32 structSignature @ 0x1E4 [[name("Structure Signature"), comment("Should be 0x72 0x72 0x41 0x61 ('rrAa')")]];
    u32 freeClusterCount @ 0x1E8 [[name("Free Cluster Count"), comment("0xFFFFFFFF if unknown")]];
    u32 nextFreeCluster @ 0x1EC [[name("Next Free Cluster")]];
    u8 reserved2[12] @ 0x1F0;
    u32 trailSignature @ 0x1FC [[name("Trail Signature"), comment("Should be 0x00 0x00 0x55 0xAA")]];
};

// Assuming FSInfo is at sector 1 (just after boot sector)
FSInfoSector fsInfo @ 512;
