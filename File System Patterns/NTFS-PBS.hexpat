// hexpat pattern for NTFS File System "Partition Boot Sector"

#pragma description NTFS boot sector and BIOS parameter block (BPB)
#pragma MIME application/x-ntfs-boot-sector
#pragma endian little

import std.core;
import std.mem;

struct BiosParameterBlock {
    u16 bytesPerSector [[comment("Usually 512 bytes (0x0200)")]];
    u8 sectorsPerCluster [[comment("If >0x80, sectors = 2^abs(value)")]];
    u16 reservedSectors [[comment("Unused by NTFS")]];
    u8 unused1[3] [[comment("Always 0")]];
    u16 unused2 [[comment("Always 0")]];
    u8 mediaDescriptor [[comment("0xF8 for hard disk")]];
    u16 unused3 [[comment("Always 0")]];
    u16 sectorsPerTrack;
    u16 numberOfHeads;
    u32 hiddenSectors [[comment("Sectors preceding partition")]];
    u32 unused4 [[comment("Not used by NTFS")]];
};

struct ExtendedParameterBlock {
    u32 unused5 [[comment("Not used by NTFS")]];
    u64 totalSectors [[comment("Partition size in sectors")]];
    u64 mftClusterNumber [[comment("$MFT cluster location")]];
    u64 mftMirrClusterNumber [[comment("$MFTMirr cluster location")]];
    s8 fileRecordSegmentSize [[comment("Clusters/bytes per file record segment")]];
    u8 unused6[3];
    s8 indexBufferSize [[comment("Clusters/bytes per index buffer")]];
    u8 unused7[3];
    u64 volumeSerialNumber;
    u32 checksum [[comment("Unused")]];
};

struct NTFSBootSector {
    u8 jmpInstruction[3] [[name("JMP Instruction"), comment("Usually 0xEB 0x52 0x90")]];
    char oemID[8] [[comment("Should be 'NTFS    '"), name("OEM ID")]];
    BiosParameterBlock bpb [[name("BIOS Parameter Block")]];
    ExtendedParameterBlock ebpb [[name("Extended Parameter Block")]];
    u8 bootstrapCode[426] [[name("Bootstrap Code")]];
    //BootSignature bootSignature @ 0x1FE [[name("Boot Signature")]];
    u16 bootSignature @ 0x1FE [[name("Boot Signature"), comment("Must be 0xAA55")]];
};

// Place the boot sector at the start of the file
NTFSBootSector bootSector @ 0x00;

// Add validations
if (bootSector.bootSignature != 0xAA55) {
    std::error("Invalid boot sector signature!");
}

if (bootSector.bpb.mediaDescriptor != 0xF8) {
    std::error("Invalid media descriptor for hard drive!");
}
