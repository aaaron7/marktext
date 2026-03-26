import { isProjectTreePathIgnored } from '../../../src/common/filesystem/paths'

const createFileInfo = isDirectory => ({
  isDirectory: () => isDirectory
})

describe('Project tree path filter', () => {
  it('includes dot-prefixed directories and markdown files', () => {
    expect(isProjectTreePathIgnored('/repo/.github', createFileInfo(true))).to.equal(false)
    expect(isProjectTreePathIgnored('/repo/.obsidian', undefined)).to.equal(false)
    expect(isProjectTreePathIgnored('/repo/.draft.md', createFileInfo(false))).to.equal(false)
    expect(isProjectTreePathIgnored('C:\\repo\\.notes.md', createFileInfo(false))).to.equal(false)
  })

  it('ignores node_modules and asar paths', () => {
    expect(isProjectTreePathIgnored('/repo/node_modules/pkg', createFileInfo(true))).to.equal(true)
    expect(isProjectTreePathIgnored('/repo/app.asar/config.md', createFileInfo(false))).to.equal(true)
    expect(isProjectTreePathIgnored('C:\\repo\\node_modules\\pkg\\index.md', createFileInfo(false))).to.equal(true)
  })

  it('still ignores non-markdown files', () => {
    expect(isProjectTreePathIgnored('/repo/image.png', createFileInfo(false))).to.equal(true)
    expect(isProjectTreePathIgnored('/repo/.env', createFileInfo(false))).to.equal(true)
    expect(isProjectTreePathIgnored('/repo/docs', createFileInfo(true))).to.equal(false)
  })
})
