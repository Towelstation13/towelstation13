import { useBackend } from '../backend';
import { Button, Collapsible, NoticeBox, Section, Stack, Box } from '../components';
import { Window } from '../layouts';

class Interaction {
  categories;
  interactions;
  descriptions;
  colors;
  self;
  ref_self;
  ref_user;
  block_interact;
}

export const InteractionMenu = (props, context) => {
  const { act, data } = useBackend<Interaction>(context);
  const {
    categories = [],
    interactions,
    descriptions,
    colors,
    self,
    ref_self,
    ref_user,
    block_interact,
  } = data;

  return (
    <Window width={500} height={600} title={'Interact - ' + self}>
      <Window.Content scrollable>
        {(block_interact && <NoticeBox>Unable to Interact</NoticeBox>) || (
          <NoticeBox>Able to Interact</NoticeBox>
        )}
        <Stack fill vertical>
          <Section key="interactions">
            {categories.map((category) => (
              <Collapsible key={category} title={category}>
                <Section fill vertical>
                  <Box mt={0.2} grow>
                    {interactions[category].map((interaction) => (
                      <Button
                        key={interaction}
                        margin={0}
                        padding={0}
                        width="150.5px"
                        lineHeight={1.75}
                        disabled={block_interact}
                        color={block_interact ? 'grey' : colors[interaction]}
                        content={interaction}
                        tooltip={descriptions[interaction]}
                        icon="exclamation-circle"
                        onClick={() =>
                          act('interact', {
                            interaction: interaction,
                            selfref: ref_self,
                            userref: ref_user,
                          })
                        }
                      />
                    ))}
                  </Box>
                </Section>
              </Collapsible>
            ))}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
